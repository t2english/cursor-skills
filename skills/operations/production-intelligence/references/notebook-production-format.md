# Production Notebook Entry Format

Format specification for `.notebook/production/` entries created by the production-intelligence skill.

These entries follow the general `.notebook/` format (see `code-navi/references/notebook-spec.md`) with additional fields specific to production findings.

## Directory Structure

```
.notebook/
├── INDEX.md
├── flows/
├── patterns/
├── gotchas/
├── corrections/
├── domain/
└── production/           ← new category
    ├── payment-timeout.md
    ├── db-connection-exhaustion.md
    ├── health-baseline.md
    └── deploy-correlation-2026-03-13.md
```

## Entry Format

### Error Pattern Entry

For recurring errors detected via Sentry or container logs:

```markdown
# Payment Timeout
> Recurring timeout on payment processing endpoint

Source: Sentry (issue PROJ-1234)
First seen: 2026-03-10
Last seen: 2026-03-13
Frequency: ~47/hour
Users affected: 230 (last 7 days)
Deploy correlation: sha-abc1234 (2026-03-10 deploy)

Error: `TimeoutError` in `src/services/payment/process.ts:charge()` (L78)
Stack: charge() → gateway.submit() → http.post() → timeout after 30s

Pattern: occurs during peak hours (14:00-18:00 UTC)
Likely cause: external payment gateway latency under load

Do instead: implement circuit breaker pattern on gateway calls;
  add retry with exponential backoff; set client-side timeout < gateway timeout

Linear: OKIA-456 (created 2026-03-13)
Updated: 2026-03-13
```

### Deploy Correlation Entry

For findings that correlate errors with specific deploys:

```markdown
# Deploy Correlation — 2026-03-13
> New errors after deploy sha-abc1234

Deploy: sha-abc1234 (PR #89, merged 2026-03-13 14:00)
Image: ghcr.io/org/app:sha-abc1234
Changes: src/services/payment/, src/middleware/auth.ts

New errors after deploy:
- PaymentTimeoutError — 47/hour (was 0 before deploy)
- AuthTokenParseError — 3/hour (was 0 before deploy)

Container health: running, 0 restarts, memory stable
App health: /health OK, /ready degraded (payment gateway slow)

Assessment: payment service changes likely caused timeout regression
Action taken: Linear issue OKIA-456 created

Updated: 2026-03-13
```

### Health Baseline Entry

Single entry tracking the application's normal health metrics. Updated on each collection.

```markdown
# Health Baseline
> Normal operating parameters for this application

Last updated: 2026-03-13

## App Health
- /health: 200 OK, ~15ms
- /ready: 200 OK, ~45ms
  - database: ok, ~5ms
  - redis: ok, ~2ms
  - payment_gateway: ok, ~120ms

## Container Health
- Containers: 3 running (api, worker, redis)
- Restarts (last 7 days): 0
- Memory: api ~180MB, worker ~120MB, redis ~50MB

## Error Baseline
- Background error rate: ~5/hour (non-critical warnings)
- Sentry unresolved: 8 issues (3 low, 4 medium, 1 high)

Updated: 2026-03-13
```

## INDEX.md Format

Production entries follow the same INDEX.md line format but use the `production` category:

```markdown
- [payment-timeout](production/payment-timeout.md) — Recurring timeout on payment endpoint, 47/hr | production | payment, timeout, sentry
- [db-connection-exhaustion](production/db-connection-exhaustion.md) — Connection pool saturating under load | production | database, pool, performance
- [health-baseline](production/health-baseline.md) — Normal operating parameters | production | health, baseline
- [deploy-correlation-2026-03-13](production/deploy-correlation-2026-03-13.md) — Errors after sha-abc1234 deploy | production | deploy, correlation
```

## Key Differences from Development Notes

| Aspect | Dev Notes | Production Notes |
|--------|-----------|------------------|
| Source | Code investigation | Sentry, Portainer, health checks |
| Entry point | `file:function()` reference | Sentry issue ID or log pattern |
| Lifecycle | Created once, updated rarely | Updated on each collection cycle |
| "Do instead" | Coding practice | Architectural/resilience pattern |
| Curation | Manual during Briefing | Automatic: resolved Sentry issues → archive |

## Curation Rules (Production-Specific)

In addition to the general curation rules from notebook-spec.md:

1. **Auto-resolve**: If a Sentry issue is marked as resolved and has not recurred for 7+ days, move the production entry to `archive/` and remove from INDEX.md.

2. **Merge correlated entries**: If multiple errors trace to the same root cause, merge them into a single entry documenting the root cause.

3. **Baseline refresh**: Update `health-baseline.md` on every collection. This is the one entry that gets fully rewritten (not appended).

4. **Deploy correlation TTL**: Deploy correlation entries older than 30 days with no associated open issues can be archived.

5. **Cap production entries**: Keep ~20 active production entries. If over the cap, archive the oldest low-severity entries.
