# Portainer API Quick Reference

Endpoints used by the ghcr-portainer-deploy skill. All requests require authentication.

Base URL: `<portainer-url>/api` (e.g. `https://portainer.example.com/api`)

## Authentication

### Option A: API Key (recommended for automation)

Generate in Portainer UI: My account > Access tokens > Add access token.

Pass as header on every request:

```
X-API-Key: <your-api-key>
```

### Option B: JWT Token (interactive use)

```
POST /api/auth
Content-Type: application/json

{
  "username": "<admin-user>",
  "password": "<password>"
}

Response: { "jwt": "<token>" }
```

Pass as header: `Authorization: Bearer <token>`

JWT tokens expire (default 8 hours). API keys do not expire and are preferred for CI/CD.

---

## Registries

### List all registries

```
GET /api/registries
```

Response: array of registry objects. Look for `URL` containing `ghcr.io`.

### Create registry (add GHCR)

```
POST /api/registries
Content-Type: application/json

{
  "type": 3,
  "name": "GHCR",
  "URL": "ghcr.io",
  "baseURL": "",
  "authentication": true,
  "username": "<github-username>",
  "password": "<github-pat>"
}
```

Registry types:
- `1` = Quay.io
- `2` = Azure Container Registry
- `3` = Custom registry
- `4` = GitLab
- `5` = ProGet
- `6` = Docker Hub
- `7` = ECR
- `8` = GitHub (GHCR)

**Note**: Type `8` is specifically for GHCR in newer Portainer versions. If type `8` is not available, use type `3` (custom) with URL `ghcr.io`.

The PAT needs `read:packages` scope. For pushing from GitHub Actions, the `GITHUB_TOKEN` handles write access separately.

### Delete registry

```
DELETE /api/registries/<registryId>
```

---

## Stacks

### List all stacks

```
GET /api/stacks
```

Response: array of stack objects. Key fields:

```json
{
  "Id": 5,
  "Name": "my-app",
  "Type": 2,
  "EndpointId": 1,
  "Status": 1,
  "CreationDate": 1710000000,
  "UpdateDate": 1710100000
}
```

- `Status`: `1` = active, `2` = inactive
- `Type`: `1` = Swarm, `2` = Compose

### Get stack by ID

```
GET /api/stacks/<stackId>
```

### Get stack compose file

```
GET /api/stacks/<stackId>/file
```

Response: `{ "StackFileContent": "<docker-compose.yml content>" }`

### Create stack (standalone/compose from string)

```
POST /api/stacks/create/standalone/string?endpointId=<endpointId>
Content-Type: application/json

{
  "name": "<stack-name>",
  "stackFileContent": "<full docker-compose.yml as string>",
  "env": [
    { "name": "VAR_NAME", "value": "var_value" }
  ]
}
```

The `stackFileContent` is the raw docker-compose.yml content as a single string. Newlines are `\n`.

`env` is optional — pass `[]` if no environment variable overrides are needed.

### Update stack

```
PUT /api/stacks/<stackId>?endpointId=<endpointId>
Content-Type: application/json

{
  "stackFileContent": "<updated docker-compose.yml>",
  "env": [],
  "prune": true
}
```

`prune: true` removes services that are no longer in the compose file.

### Redeploy stack (pull new images)

```
POST /api/stacks/<stackId>/redeploy?endpointId=<endpointId>
Content-Type: application/json

{
  "pullImage": true,
  "env": []
}
```

`pullImage: true` forces Portainer to pull the latest image from the registry before restarting. This is the key call for continuous deployment — after a new image is pushed to GHCR, this endpoint makes Portainer pull and redeploy it.

### Start stack

```
POST /api/stacks/<stackId>/start?endpointId=<endpointId>
```

### Stop stack

```
POST /api/stacks/<stackId>/stop?endpointId=<endpointId>
```

### Delete stack

```
DELETE /api/stacks/<stackId>?endpointId=<endpointId>
```

---

## Containers (via Docker API proxy)

Portainer proxies Docker Engine API requests through its endpoint proxy.

### List containers

```
GET /api/endpoints/<endpointId>/docker/containers/json?all=true
```

Filter by stack name using label filter:

```
GET /api/endpoints/<endpointId>/docker/containers/json?filters={"label":["com.docker.compose.project=<stack-name>"]}
```

### Container logs

```
GET /api/endpoints/<endpointId>/docker/containers/<containerId>/logs?stdout=true&stderr=true&tail=100&timestamps=true
```

Returns raw log output. `tail=100` limits to last 100 lines.

### Container inspect

```
GET /api/endpoints/<endpointId>/docker/containers/<containerId>/json
```

Key fields for health verification:
- `State.Status`: `running`, `exited`, `restarting`
- `State.Health.Status`: `healthy`, `unhealthy`, `starting` (if HEALTHCHECK defined)

---

## Environments (Endpoints)

### List environments

```
GET /api/endpoints
```

Returns available Docker environments. The `Id` field is the `endpointId` used in other calls.

Most single-node setups have one endpoint with `Id: 1`.

---

## Error Handling

Common HTTP status codes:

| Code | Meaning | Action |
|------|---------|--------|
| 200 | Success | Proceed |
| 400 | Bad request | Check request body format |
| 401 | Unauthorized | API key invalid or expired |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not found | Stack/container/registry ID doesn't exist |
| 409 | Conflict | Stack name already exists (on create) |
| 500 | Server error | Check Portainer logs |

All error responses include a `message` field with details:

```json
{
  "message": "Stack not found",
  "details": "stack with ID 99 not found"
}
```
