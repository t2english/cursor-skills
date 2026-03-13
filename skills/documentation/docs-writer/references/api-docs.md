# API Documentation Template

Use this template when documenting new or changed API endpoints.

## Endpoint Template

For each endpoint, document the following:

```markdown
### <METHOD> <path>

<One-line description of what the endpoint does.>

**Auth**: <required/optional/none> — <token type if applicable>

#### Request

| Parameter | Type   | Required | Description |
|-----------|--------|----------|-------------|
| `param`   | string | yes      | Description |

**Body** (if applicable):

```json
{
  "field": "value"
}
```

#### Response

**200 OK**

```json
{
  "id": "uuid",
  "field": "value"
}
```

**Error responses**:

| Status | Code            | Description                |
|--------|-----------------|----------------------------|
| 400    | VALIDATION_ERROR | Invalid request body       |
| 401    | UNAUTHORIZED     | Missing or invalid token   |
| 404    | NOT_FOUND        | Resource does not exist    |
| 429    | RATE_LIMITED     | Too many requests          |

#### Example

```bash
curl -X <METHOD> <base-url><path> \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"field": "value"}'
```
```

## Full API Document Structure

```markdown
# <Service Name> API

Base URL: `https://api.example.com/v1`

## Authentication

<Describe auth mechanism: Bearer token, API key, OAuth2, etc.>

## Rate Limits

<Requests per minute/hour, rate limit headers returned>

## Pagination

<Cursor-based or offset-based, parameters, default page size>

## Endpoints

### Resource A

#### GET /resource-a
#### POST /resource-a
#### GET /resource-a/:id
#### PATCH /resource-a/:id
#### DELETE /resource-a/:id

### Resource B

...

## Error Format

All errors follow this structure:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable description"
  }
}
```

## Changelog

| Date       | Change                    |
|------------|---------------------------|
| YYYY-MM-DD | Added endpoint X          |
| YYYY-MM-DD | Deprecated field Y        |
```

## Checklist

Before finalizing API docs, verify:

- [ ] Every endpoint has method, path, description, auth, request, response, and errors
- [ ] Request/response examples use realistic data (not "foo" or "bar")
- [ ] Error codes match actual implementation
- [ ] curl/fetch examples are copy-pasteable and work
- [ ] Pagination and rate limit behavior is documented
- [ ] Breaking changes are clearly marked
