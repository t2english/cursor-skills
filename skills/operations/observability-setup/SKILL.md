---
name: observability-setup
description: Workflow for setting up and improving application observability — structured logging, metrics, tracing, health checks, and alerting. Supports Node.js, Python, and Go. Integrates with Sentry MCP for error tracking. Use when setting up monitoring, adding logging, creating health checks, configuring alerts, or improving observability posture. Triggers on "add logging", "set up monitoring", "health check", "add metrics", "observability", "set up tracing", "configure alerts", "Sentry setup". Do NOT use for debugging specific incidents (use incident-response) or performance optimization (use performance-audit).
metadata:
  author: T2E
  version: "1.1.0"
---

# Observability Setup

Make your system observable. If you can't see it, you can't fix it.

## The Three Pillars

```
Logs    → What happened (discrete events)
Metrics → How much/how often (aggregated numbers)
Traces  → The journey of a request (distributed path)
```

## Step 1: Detect Stack

Identify the runtime and existing observability setup:

```
1. Language/runtime: Node.js, Python, Go
2. Framework: Express, Fastify, Flask, Django, Gin, Echo
3. Existing logging: console.log, winston, pino, structlog, slog
4. Existing metrics: prometheus client, OpenTelemetry, StatsD
5. Existing error tracking: Sentry, Bugsnag, Rollbar
6. Deployment: Docker, K8s, serverless, VPS
```

## Step 2: Structured Logging

Replace unstructured logs with structured JSON:

**Node.js** (recommend pino for performance):
```typescript
import pino from 'pino';
const logger = pino({ level: process.env.LOG_LEVEL || 'info' });
logger.info({ userId, action: 'login' }, 'User logged in');
```

**Python** (recommend structlog):
```python
import structlog
logger = structlog.get_logger()
logger.info("user_logged_in", user_id=user_id, action="login")
```

**Go** (recommend slog, stdlib since 1.21):
```go
slog.Info("user logged in", "userId", userId, "action", "login")
```

Key principles:
- Log events, not sentences: `"order_created"` not `"An order was created by the user"`
- Include correlation IDs (request ID, user ID, trace ID)
- Use levels correctly: ERROR (broken), WARN (degraded), INFO (notable), DEBUG (development)
- Never log sensitive data (passwords, tokens, PII)

## Step 3: Health Checks

Every service should expose:

- `GET /health` → basic liveness (returns 200 if process is running)
- `GET /ready` → readiness (returns 200 if dependencies are connected: DB, cache, external APIs)

```json
// /ready response example
{
  "status": "ok",
  "checks": {
    "database": { "status": "ok", "latency_ms": 5 },
    "redis": { "status": "ok", "latency_ms": 2 },
    "external_api": { "status": "degraded", "latency_ms": 1200 }
  }
}
```

## Step 4: Error Tracking (Sentry)

If Sentry MCP (`user-sentry`) is available:
- Use it to query recent errors and their frequency
- Set up Sentry SDK in the application
- Configure source maps (JS/TS) for readable stack traces
- Set up release tracking to correlate errors with deployments
- Define alert rules for new error spikes

## Step 5: Metrics

Key metrics every service should track:

- **Request rate**: requests per second by endpoint
- **Error rate**: 4xx and 5xx responses per second
- **Latency**: p50, p95, p99 response times
- **Saturation**: CPU, memory, connection pool usage

For OpenTelemetry setup, use auto-instrumentation when available.

## Step 6: Alerting Guidelines

Create alerts for:

- **Critical** (page immediately): error rate > 5%, health check failing, data loss risk
- **Warning** (notify, don't page): latency p99 > 2s, memory > 80%, disk > 85%
- **Info** (dashboard only): deployment completed, traffic anomaly

Avoid alert fatigue: every alert should be actionable. If you can't act on it, it's a dashboard metric, not an alert.

## Step 7: Post-Deploy Performance Watch

After setting up observability for a new deploy, monitor key metrics for the first 15-30 minutes:

- If **latency p95 increases by >20%** compared to pre-deploy baseline, flag it.
- If **error rate increases by >1%**, flag it.
- If **memory/CPU usage climbs steadily** without leveling off, flag it.

When degradation is detected and the `performance-audit` skill is available, suggest it:
"Metrics show latency degradation after deploy. Want me to run a performance audit to identify the bottleneck?"

If `incident-response` thresholds are hit (error rate >5%, health check failing), escalate to that skill instead.

## Integration

- **incident-response**: triggered when alerts fire or errors spike
- **deploy-release**: post-deploy monitoring verification
- **performance-audit**: suggested when metrics show degradation after deploy
