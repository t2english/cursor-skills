---
name: ghcr-portainer-deploy
description: Build Docker images via GitHub Actions, push to GHCR, and deploy stacks on Portainer via API. Handles the full container pipeline — image build, registry push, stack creation/update, redeploy with pull, health verification, and rollback. Use when deploying containerized apps, setting up CI/CD for Docker, pushing to GHCR, deploying to Portainer, or managing Portainer stacks. Triggers on "deploy to portainer", "push image", "build and deploy", "ghcr", "portainer stack", "container deploy", "update stack", "redeploy". Do NOT use for non-Docker deployments like Vercel/Netlify (use deploy-release) or CI debugging (use gh-fix-ci).
---

# GHCR + Portainer Deploy

Automated container pipeline: build image, push to GHCR, deploy stack on Portainer.

## Configuration

Read `.cursor/deploy.json` in the project root before any operation:

```json
{
  "ghcr": {
    "owner": "<github-owner-or-org>",
    "imageName": "<image-name>"
  },
  "portainer": {
    "url": "https://portainer.example.com",
    "endpointId": 1,
    "stackName": "<stack-name>",
    "composeFile": "docker-compose.yml"
  }
}
```

If the file doesn't exist, ask the developer for these values before proceeding. Never guess registry owners or Portainer URLs.

### Required Secrets (GitHub Repository)

These must be configured in GitHub repo Settings > Secrets and variables > Actions:

```
PORTAINER_URL       — Portainer instance base URL (e.g. https://portainer.example.com)
PORTAINER_API_KEY   — Portainer API key (generated in Portainer > My account > Access tokens)
PORTAINER_STACK_ID  — Numeric ID of the Portainer stack (from GET /api/stacks)
PORTAINER_ENDPOINT_ID — Portainer environment/endpoint ID (default: 1)
```

`GITHUB_TOKEN` is provided automatically by GitHub Actions with GHCR write permissions.

## Phase 1: Ensure GitHub Actions Workflow

Check if `.github/workflows/deploy.yml` (or similar) exists:

```
1. Look for .github/workflows/ directory
2. Search for workflow files that reference ghcr.io or docker/build-push-action
3. If found: verify it matches the expected structure (see references/github-actions-workflow.md)
4. If NOT found: generate the workflow from the template
```

When generating the workflow:

```
1. Read references/github-actions-workflow.md for the full template
2. Adapt to the project:
   - Set image name from deploy.json config
   - Detect Dockerfile location (root or subdirectory)
   - Set trigger branch (default: main)
3. Write .github/workflows/deploy.yml
4. Commit and push the workflow file
```

The workflow handles:
- Trigger on push to main (and optionally on version tags `v*`)
- Login to GHCR via `docker/login-action`
- Tag generation via `docker/metadata-action` (`:latest`, `:v1.2.3`, `:sha-<short>`)
- Build + push via `docker/build-push-action` with GitHub Actions cache
- Post-push step that calls Portainer API to redeploy the stack

## Phase 2: Register GHCR in Portainer

Before Portainer can pull images from GHCR, the registry must be registered.

```
1. List existing registries:
   GET <portainer-url>/api/registries
   Header: X-API-Key: <api-key>

2. Check if ghcr.io is already registered:
   - Look for entry with URL containing "ghcr.io"
   - If found: skip to Phase 3

3. If NOT registered, create it:
   POST <portainer-url>/api/registries
   Header: X-API-Key: <api-key>
   Body: {
     "type": 3,
     "name": "GHCR",
     "URL": "ghcr.io",
     "authentication": true,
     "username": "<github-username>",
     "password": "<github-pat-with-read-packages>"
   }

4. Note the returned registry ID for stack configuration
```

Registry type `3` = custom registry. The PAT needs `read:packages` scope at minimum.

This phase is typically a one-time setup. Once registered, all stacks can pull from GHCR.

## Phase 3: Create or Update Stack

```
1. List existing stacks:
   GET <portainer-url>/api/stacks
   Header: X-API-Key: <api-key>

2. Find stack by name (from deploy.json config):
   - Filter results where Name == stackName

3a. If stack DOES NOT exist — CREATE:
    POST <portainer-url>/api/stacks/create/standalone/string?endpointId=<endpointId>
    Header: X-API-Key: <api-key>
    Body: {
      "name": "<stackName>",
      "stackFileContent": "<docker-compose.yml content>",
      "env": []
    }

    Read the compose file from the path specified in deploy.json.
    Replace image tags with the GHCR image reference:
      ghcr.io/<owner>/<imageName>:latest

3b. If stack EXISTS — UPDATE + REDEPLOY:
    PUT <portainer-url>/api/stacks/<stackId>?endpointId=<endpointId>
    Header: X-API-Key: <api-key>
    Body: {
      "stackFileContent": "<updated docker-compose.yml content>",
      "env": [],
      "prune": true
    }

    Then force a pull + redeploy:
    POST <portainer-url>/api/stacks/<stackId>/redeploy?endpointId=<endpointId>
    Header: X-API-Key: <api-key>
    Body: {
      "pullImage": true,
      "env": []
    }
```

When the GitHub Actions workflow triggers this automatically, it uses the Portainer API key from secrets to call the redeploy endpoint after pushing the image.

## Phase 4: Post-Deploy Verification

```
1. Wait 15-30 seconds for containers to start

2. Check stack status via Portainer API:
   GET <portainer-url>/api/stacks/<stackId>
   - Status should be 1 (active)

3. Check container health:
   GET <portainer-url>/api/endpoints/<endpointId>/docker/containers/json
   - Filter by stack label
   - All containers should be "running"
   - If health check configured: status should be "healthy"

4. Hit the application health endpoint (if configured):
   GET <app-url>/health  or  /api/health  or  /ready
   - Expect 200 OK

5. If verification FAILS:
   a. Check container logs via Portainer API:
      GET <portainer-url>/api/endpoints/<endpointId>/docker/containers/<id>/logs?stdout=true&stderr=true&tail=100
   b. Report the failure with log excerpt
   c. Offer rollback (see Rollback section)

6. After verification (success or failure):
   - If production-intelligence skill is available, invoke it to:
     a. Collect Sentry errors and container logs for this deploy
     b. Record deploy outcome in .deploys/log.md audit trail
     c. Create/update .notebook/production/ entries for any findings
     d. Correlate new errors with this deploy's commit SHA
   - "Deploy verified. Want me to run production intelligence to check for errors and update the audit trail?"
```

## Rollback

If the deploy fails or causes issues:

```
1. Identify the previous working image tag:
   - Check GHCR for previous tags (gh api /user/packages/container/<imageName>/versions)
   - Or use the git SHA of the last known good commit

2. Update the stack compose to pin the previous tag:
   ghcr.io/<owner>/<imageName>:<previous-tag>

3. Redeploy with the pinned tag:
   POST <portainer-url>/api/stacks/<stackId>/redeploy?endpointId=<endpointId>
   Body: { "pullImage": true, "env": [] }

4. Verify the rollback (repeat Phase 4)

5. Create an incident issue in Linear if available (see _shared/references/linear-helpers.md)
```

## Integration

- **deploy-release**: this skill is a concrete implementation of the Docker deploy strategy; deploy-release handles versioning, release notes, and pre-deploy checklists
- **finalize-branch**: merges the code that triggers the GitHub Actions workflow
- **gh-fix-ci**: invoked if the deploy workflow fails in GitHub Actions
- **incident-response**: invoked if deploy verification fails in production
- **production-intelligence**: collects production data post-deploy, records in `.notebook/production/`, maintains audit trail
- **linear-project-management**: updates issue status post-deploy (see _shared/references/linear-helpers.md)
- **observability-setup**: monitors the deployed application

## Quick Reference: Common Commands

```bash
# Check GHCR image tags
gh api /user/packages/container/<imageName>/versions --jq '.[].metadata.container.tags'

# Trigger a manual redeploy via Portainer API
curl -X POST "<portainer-url>/api/stacks/<stackId>/redeploy?endpointId=<endpointId>" \
  -H "X-API-Key: <api-key>" \
  -H "Content-Type: application/json" \
  -d '{"pullImage": true, "env": []}'

# Check stack status
curl -s "<portainer-url>/api/stacks/<stackId>" \
  -H "X-API-Key: <api-key>" | jq '.Status, .Name'

# View container logs
curl -s "<portainer-url>/api/endpoints/<endpointId>/docker/containers/<containerId>/logs?stdout=true&stderr=true&tail=50" \
  -H "X-API-Key: <api-key>"
```
