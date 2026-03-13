---
name: production-intelligence
description: Close the feedback loop between production and development. Collects data from Sentry, Portainer logs, and health endpoints, analyzes patterns, records findings in `.notebook/production/`, creates Linear issues for recurring problems, and maintains a deploy audit trail. Use after deploys, when checking production health, auditing deploy history, or investigating recurring errors proactively. Triggers on "check production", "production status", "what errors in prod", "audit deploys", "production health", "check sentry", "deploy history", "feedback loop", "production intelligence". Do NOT use for active incident response (use incident-response) or setting up monitoring infrastructure (use observability-setup).
---

# Production Intelligence

Close the feedback loop. Production data feeds development decisions.

## Configuration

This skill reuses existing project configs. No new config file required.

**Required** (at least one):
- `.cursor/deploy.json` — Portainer URL, endpoint ID, stack name (from ghcr-portainer-deploy)
- Sentry MCP (`user-sentry`) — error tracking data

**Optional**:
- `.cursor/linear.json` — for creating issues from findings (see `_shared/references/linear-helpers.md`)
- Application health endpoint URL — detected from deploy config or asked from developer

If neither Sentry nor Portainer config is available, inform the developer and skip to whatever sources are accessible. Never fail the workflow because one source is unavailable.

## When to Invoke

- **Post-deploy** (proactive): after ghcr-portainer-deploy completes Phase 4, run a quick collection
- **On demand**: developer asks "check production", "what's happening in prod", "any errors?"
- **MONITOR phase**: feature-lifecycle step 12 invokes this after observability-setup verification
- **Periodic**: suggest running at the start of a new sprint or after a release batch

## Phase 1: Collect

Gather data from all available production sources. Query in parallel when possible.

### Sentry (if MCP available)

```
1. Check if user-sentry MCP is authenticated
   - If not: attempt CallMcpTool("user-sentry", "mcp_auth", {})
   - If still unavailable: skip Sentry, note "Sentry unavailable" and continue

2. List unresolved issues (sorted by frequency):
   - See references/sentry-queries.md for query patterns
   - Capture: title, count, first/last seen, affected users

3. Identify NEW issues since last collection:
   - Compare with .notebook/production/ entries (if they exist)
   - New = not yet documented in notebook

4. Get stack traces for top 3 errors by frequency
```

### Portainer (if deploy.json available)

```
1. Read .cursor/deploy.json for Portainer URL, endpoint, stack
2. Check stack status:
   GET <portainer-url>/api/stacks/<stackId>
   - Is stack active (Status == 1)?

3. Check container health:
   GET <portainer-url>/api/endpoints/<endpointId>/docker/containers/json?filters={"label":["com.docker.compose.project=<stackName>"]}
   - State: running/restarting/exited
   - Health: healthy/unhealthy/starting
   - RestartCount: flag if > 0 since last deploy

4. Pull recent container logs (last 200 lines):
   GET <portainer-url>/api/endpoints/<endpointId>/docker/containers/<id>/logs?stdout=true&stderr=true&tail=200&timestamps=true
   - Scan for ERROR/WARN/FATAL patterns
   - Extract structured log fields if JSON logging is used
```

### Health Endpoints

```
1. Hit the application health endpoint:
   GET <app-url>/health  or  /api/health  or  /ready
   - Record response time and status
   - If /ready exists: check individual dependency statuses

2. Compare with baseline (if .notebook/production/health-baseline.md exists):
   - Latency increased > 20%? Flag it.
   - Any dependency degraded? Flag it.
```

### Deploy History

```
1. Recent GitHub Actions runs:
   gh run list --workflow=deploy.yml --limit=10 --json conclusion,createdAt,headSha,headBranch

2. Recent git tags:
   git tag --sort=-creatordate | head -10

3. GHCR image versions (if deploy.json exists):
   gh api /user/packages/container/<imageName>/versions --jq '.[0:10] | .[].metadata.container.tags'
```

## Phase 2: Analyze

Process collected data into actionable findings.

### Error Patterns

```
For each Sentry issue or log error pattern:
1. Is it recurring? (appeared in multiple deploys/days)
2. When did it start? (correlate with deploy dates from Phase 1)
3. What is the impact? (users affected, frequency per hour/day)
4. Is it already documented in .notebook/production/? (update vs create)
```

### Deploy Correlations

```
1. Map: deploy timestamp → new errors that appeared after
2. If a deploy consistently introduces errors, flag the commit SHA
3. Check if any deploy caused container restarts (RestartCount spike)
```

### Health Trends

```
1. Compare current health with baseline
2. Flag: latency drift, new degraded dependencies, intermittent failures
3. If containers are restarting: likely memory leak or crash loop
```

### Severity Classification

Classify each finding:

- **Critical**: service down, data loss risk, error rate > 5% → suggest `incident-response`
- **High**: recurring errors affecting users, container restarts → create Linear issue
- **Medium**: performance degradation, non-critical errors → document in notebook, suggest `performance-audit`
- **Low**: occasional warnings, minor anomalies → document in notebook only

## Phase 3: Record

Store findings for cross-session persistence.

### Production Notebook Entries

Create or update entries in `.notebook/production/`:

```
1. For each significant finding from Phase 2:
   a. Check .notebook/INDEX.md for existing production entry
   b. If exists: update with new data (last seen, frequency, etc.)
   c. If new: create entry following references/notebook-production-format.md

2. Update .notebook/INDEX.md:
   - Add new entries with category "production"
   - Sort production entries by severity/recency
```

See `references/notebook-production-format.md` for the entry format.

### Deploy Audit Trail

Append to `.deploys/log.md` (create if it doesn't exist):

```markdown
## YYYY-MM-DD HH:MM — v<version> / sha-<short>

- **Image**: ghcr.io/<owner>/<app>:<tag>
- **Trigger**: merge of PR #<number> / manual
- **Result**: success / failed (reason)
- **Errors post-deploy**: none / <count> new Sentry issues
- **Health**: all green / degraded (<details>)
- **Linear**: <issue-ids> moved to Done
```

The audit trail is append-only. Never delete entries. Cap at ~100 entries; older entries can be archived to `.deploys/archive/`.

## Phase 4: Act

Turn findings into actions.

### Present Summary to Developer

Always show a concise production status report:

```
Production Status — <app-name> — <date>

Health: OK / DEGRADED / DOWN
Containers: 3/3 running, 0 restarts
Last deploy: <date> (sha-<short>)

Errors (Sentry):
  [NEW] PaymentTimeoutError — 47/hour, 230 users affected, since deploy sha-abc123
  [RECURRING] DatabaseConnectionExhausted — 12/hour, stable since 3 days
  [RESOLVED] AuthTokenExpired — 0 occurrences in last 24h

Recommendations:
  1. [HIGH] Investigate PaymentTimeoutError — correlates with last deploy
  2. [MEDIUM] Database connection pool may need tuning — see .notebook/production/db-connection-exhaustion.md
```

### Create Linear Issues

For High/Critical findings not yet tracked:

```
1. Check Linear for existing issues matching the error pattern
   (search by error name or description)
2. If no existing issue: create one via _shared/references/linear-helpers.md
   - Title: "[Prod] <error-name> — <impact summary>"
   - Description: include Sentry link, frequency, deploy correlation, affected code pointers
   - Label: "bug", priority based on severity
3. If existing issue: add comment with latest data
```

### Suggest Next Steps

Based on findings, suggest invoking other skills:

- Critical/service down → "Invoke `incident-response` for structured incident handling"
- Performance degradation → "Invoke `performance-audit` to profile and optimize"
- Security-related errors → "Invoke `security-best-practices` for a targeted review"
- No issues found → "Production looks healthy. No action needed."

## Phase 5: Feed Back

The recorded intelligence flows back into development automatically:

```
Next development session:
1. code-navi reads .notebook/INDEX.md during Briefing
   → sees production/ entries tagged with relevant modules
   → agent has production context before implementing changes

2. spec-driven reads .notebook/ during Design phase
   → production error patterns inform design decisions
   → "This module has recurring timeout issues — design for resilience"

3. linear-project-management sees production-created issues
   → issues enter sprint planning with real impact data
   → prioritization based on user-facing severity

4. incident-response uses .notebook/production/ during investigation
   → "This error pattern was seen before — see production/payment-timeout.md"
   → faster root cause identification
```

No manual intervention needed. The `.notebook/production/` entries become part of the project's accumulated intelligence.

## Graceful Degradation

This skill works with whatever is available:

| Source | Available | Unavailable |
|--------|-----------|-------------|
| Sentry MCP | Full error analysis | Skip error collection, note "Sentry unavailable" |
| Portainer API | Container logs + health | Skip container data, note "Portainer unavailable" |
| Health endpoints | Latency + dependency check | Skip health baseline |
| Linear MCP | Create/update issues | Log findings without issue creation |
| `.notebook/` | Full persistence | Create `.notebook/` + `production/` directory |

Minimum viable run: at least ONE source available. If zero sources, inform the developer and suggest setting up Sentry (via `observability-setup`) or Portainer (via `ghcr-portainer-deploy`).

## Integration

- **observability-setup**: sets up the monitoring infrastructure; this skill consumes the data it produces
- **incident-response**: escalation path for critical findings; postmortem findings feed back here
- **ghcr-portainer-deploy**: triggers this skill after deploy verification (Phase 4)
- **code-navi**: reads `.notebook/production/` during Briefing for production context
- **performance-audit**: invoked when performance degradation is detected
- **linear-project-management**: issues created from production findings (see `_shared/references/linear-helpers.md`)
- **feature-lifecycle**: invoked during MONITOR phase to close the feedback loop
