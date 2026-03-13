---
name: incident-response
description: Structured workflow for responding to production incidents — from detection through resolution to postmortem. Integrates with Sentry MCP for error investigation and Linear for follow-up tracking. Use when production is broken, errors are spiking, users report issues, or after an outage for postmortem. Triggers on "production is down", "error spike", "incident", "outage", "postmortem", "something broke in prod", "users are reporting", "Sentry alert", "investigate production error". Do NOT use for development debugging (use code-navi) or CI failures (use gh-fix-ci).
metadata:
  author: T2E
  version: "1.0.0"
---

# Incident Response

When production breaks, every minute counts. Follow the process. Stay calm.

## Severity Classification

- **P1 Critical**: Service completely down, data loss, security breach. Drop everything.
- **P2 High**: Major feature broken, significant user impact. Respond within 30 minutes.
- **P3 Medium**: Degraded performance, partial feature failure. Respond within 2 hours.
- **P4 Low**: Minor issue, workaround exists. Handle in normal workflow.

## Phase 1: Detect and Triage

```
1. What is the symptom? (error message, user report, alert)
2. When did it start? (deploy? traffic spike? external dependency?)
3. What is the blast radius? (all users? specific region? one feature?)
4. Is there a workaround? (feature flag, fallback, manual process?)
5. Assign severity (P1-P4)
```

If Sentry MCP (`user-sentry`) is available:
- Query recent errors: look for new error types or sudden spikes
- Check error frequency and affected users
- Get stack traces for the top errors

## Phase 2: Investigate

Follow the hypothesis-driven approach:

```
1. Form hypothesis: "The deploy at 14:00 introduced a bug in payment processing"
2. Gather evidence: logs, metrics, traces, error reports
3. Test hypothesis: does the evidence support it?
4. If no: form new hypothesis, repeat
5. If yes: proceed to fix
```

Investigation tools:
- Application logs (structured logs with correlation IDs)
- Error tracking (Sentry, if MCP available)
- Metrics dashboards (Grafana, Datadog)
- Database query logs
- Recent deployment history: `git log --oneline -10`

## Phase 3: Mitigate

Stop the bleeding before finding the root cause:

```
Priority order (fastest first):
1. Feature flag: disable the broken feature
2. Rollback: deploy the previous version
3. Hotfix: minimal code change to stop the error
4. Scale: add capacity if it's a load issue
```

Communicate status: notify the team with current status and ETA.

## Phase 4: Resolve

Once mitigated, fix properly:

1. Identify root cause (not just the symptom)
2. Write a test that reproduces the issue (invoke testing-strategy if available)
3. Implement the fix
4. Deploy to staging, verify
5. Deploy to production, monitor for 30 minutes

Update Linear: see `_shared/references/linear-helpers.md` for status updates.

## Phase 5: Postmortem

After every P1/P2 incident, write a postmortem. No blame, only learning.

### Postmortem Template

```markdown
# Postmortem: [Incident Title]

**Date**: YYYY-MM-DD
**Duration**: [start time] to [resolution time]
**Severity**: P1/P2
**Author**: [name]

## Summary
[1-2 sentence description of what happened]

## Timeline
- HH:MM - [Event: what happened]
- HH:MM - [Detection: how we found out]
- HH:MM - [Response: what we did]
- HH:MM - [Resolution: when it was fixed]

## Root Cause
[Technical explanation of why it happened]

## Impact
- Users affected: [number/percentage]
- Duration: [minutes/hours]
- Data impact: [any data loss or corruption]

## What Went Well
- [Things that helped during response]

## What Could Be Better
- [Things that slowed response or made it harder]

## Action Items
- [ ] [Preventive measure] — owner: [name], due: [date]
- [ ] [Monitoring improvement] — owner: [name], due: [date]
- [ ] [Process improvement] — owner: [name], due: [date]
```

Create follow-up issues in Linear for each action item.

## Integration

- **observability-setup**: provides the monitoring that detects incidents
- **deploy-release**: rollback procedures
- **linear-project-management**: follow-up issue tracking
- **testing-strategy**: reproduction tests for incidents
