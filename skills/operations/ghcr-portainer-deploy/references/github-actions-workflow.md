# GitHub Actions Workflow Template: GHCR + Portainer

Reference template for the deploy workflow. Adapt values marked with `<placeholders>` to the target project.

## Full Workflow

```yaml
name: Build, Push GHCR & Deploy Portainer

on:
  push:
    branches: [main]
    tags: ["v*"]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata (tags, labels)
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=sha,prefix=sha-
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Deploy to Portainer
        if: github.ref == 'refs/heads/main'
        run: |
          curl -X POST \
            "${{ secrets.PORTAINER_URL }}/api/stacks/${{ secrets.PORTAINER_STACK_ID }}/redeploy?endpointId=${{ secrets.PORTAINER_ENDPOINT_ID }}" \
            -H "X-API-Key: ${{ secrets.PORTAINER_API_KEY }}" \
            -H "Content-Type: application/json" \
            -d '{"pullImage": true, "env": []}'
```

## Key Components

### Trigger Strategy

- **Push to main**: every merge triggers build + deploy (continuous deployment)
- **Version tags** (`v*`): also triggers on `git tag -a v1.2.3 -m "Release"` + push

To switch to tag-only deploys (manual release control), remove `branches: [main]`.

### Image Tagging

The `docker/metadata-action` generates multiple tags per build:

| Tag Pattern | Example | Purpose |
|-------------|---------|---------|
| `latest` | `ghcr.io/org/app:latest` | Always points to newest main build |
| `sha-<short>` | `ghcr.io/org/app:sha-a1b2c3d` | Immutable, traceable to exact commit |
| `v1.2.3` | `ghcr.io/org/app:v1.2.3` | Semver release (only on version tags) |
| `v1.2` | `ghcr.io/org/app:v1.2` | Major.minor floating tag |
| `main` | `ghcr.io/org/app:main` | Branch name |

### Build Cache

Uses GitHub Actions cache (`type=gha`) for layer caching. This significantly speeds up builds when only application code changes (base layers are cached).

### Portainer Redeploy Step

The final step calls Portainer's redeploy API with `pullImage: true`, which forces Portainer to pull the latest image from GHCR before restarting containers.

Required secrets in the GitHub repository:

| Secret | Description | Where to find |
|--------|-------------|---------------|
| `PORTAINER_URL` | Base URL of the Portainer instance | e.g. `https://portainer.example.com` |
| `PORTAINER_API_KEY` | API access token | Portainer > My account > Access tokens |
| `PORTAINER_STACK_ID` | Numeric stack ID | `GET /api/stacks` response, field `Id` |
| `PORTAINER_ENDPOINT_ID` | Environment/endpoint ID | Portainer > Environments (usually `1`) |

`GITHUB_TOKEN` is automatic — no setup needed. It has `packages:write` via the `permissions` block.

## Variations

### Monorepo (subdirectory Dockerfile)

```yaml
      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: ./apps/api
          file: ./apps/api/Dockerfile
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### Multi-service (multiple images)

Use a matrix strategy:

```yaml
jobs:
  build-and-push:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        service:
          - { name: api, context: ./apps/api }
          - { name: web, context: ./apps/web }
          - { name: worker, context: ./apps/worker }
    permissions:
      contents: read
      packages: write
    steps:
      # ... same steps but with:
      # IMAGE_NAME: ghcr.io/<owner>/${{ matrix.service.name }}
      # context: ${{ matrix.service.context }}
```

### Build args and multi-stage

```yaml
      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          build-args: |
            NODE_ENV=production
            APP_VERSION=${{ github.sha }}
          target: production
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### Deploy with health check wait

Replace the simple curl with a script that waits for the app to be healthy:

```yaml
      - name: Deploy to Portainer
        if: github.ref == 'refs/heads/main'
        run: |
          # Trigger redeploy
          curl -sf -X POST \
            "${{ secrets.PORTAINER_URL }}/api/stacks/${{ secrets.PORTAINER_STACK_ID }}/redeploy?endpointId=${{ secrets.PORTAINER_ENDPOINT_ID }}" \
            -H "X-API-Key: ${{ secrets.PORTAINER_API_KEY }}" \
            -H "Content-Type: application/json" \
            -d '{"pullImage": true, "env": []}'

          # Wait for healthy (up to 60s)
          for i in $(seq 1 12); do
            sleep 5
            STATUS=$(curl -sf "${{ secrets.PORTAINER_URL }}/api/stacks/${{ secrets.PORTAINER_STACK_ID }}" \
              -H "X-API-Key: ${{ secrets.PORTAINER_API_KEY }}" | jq -r '.Status')
            if [ "$STATUS" = "1" ]; then
              echo "Stack is active"
              exit 0
            fi
            echo "Waiting... attempt $i/12"
          done
          echo "Deploy verification timed out"
          exit 1
```
