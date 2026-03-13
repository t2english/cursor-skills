# Sentry MCP Query Patterns

Reference for querying production error data via the Sentry MCP (`user-sentry`).

## Prerequisites

The Sentry MCP must be authenticated. If tools are not available:

```
CallMcpTool("user-sentry", "mcp_auth", {})
```

This triggers the OAuth flow. After authentication, Sentry tools become available.

## Common Queries

### List Unresolved Issues

Get all unresolved issues for the project, sorted by frequency:

```
CallMcpTool("user-sentry", "list_issues", {
  organizationSlug: "<org>",
  projectSlug: "<project>",
  query: "is:unresolved",
  sortBy: "freq"
})
```

Key fields in response:
- `title` — error message/type
- `count` — total occurrences
- `userCount` — unique users affected
- `firstSeen` — when the error first appeared
- `lastSeen` — most recent occurrence
- `shortId` — human-readable issue ID
- `permalink` — link to Sentry UI

### Issues Since a Specific Date

Filter issues that appeared after a deploy:

```
CallMcpTool("user-sentry", "list_issues", {
  organizationSlug: "<org>",
  projectSlug: "<project>",
  query: "is:unresolved firstSeen:>2026-03-13T00:00:00"
})
```

Replace the date with the deploy timestamp to find errors introduced by that deploy.

### Top Errors by Event Count

```
CallMcpTool("user-sentry", "list_issues", {
  organizationSlug: "<org>",
  projectSlug: "<project>",
  query: "is:unresolved times_seen:>10",
  sortBy: "freq",
  limit: 10
})
```

### Get Issue Details and Stack Trace

Once you have an issue ID:

```
CallMcpTool("user-sentry", "get_issue", {
  issueId: "<issue-id>"
})
```

For the latest event with full stack trace:

```
CallMcpTool("user-sentry", "get_latest_event", {
  issueId: "<issue-id>"
})
```

Key fields in event response:
- `entries` — contains exception stack trace
- `tags` — environment, browser, OS, etc.
- `contexts` — runtime, device, OS info
- `user` — affected user details (if configured)

### Errors by Tag (Environment, Release)

Filter by deployment environment:

```
CallMcpTool("user-sentry", "list_issues", {
  organizationSlug: "<org>",
  projectSlug: "<project>",
  query: "is:unresolved environment:production"
})
```

Filter by release/version:

```
CallMcpTool("user-sentry", "list_issues", {
  organizationSlug: "<org>",
  projectSlug: "<project>",
  query: "is:unresolved release:<version>"
})
```

### Recently Resolved Issues

Check what was recently fixed (useful for postmortem and audit):

```
CallMcpTool("user-sentry", "list_issues", {
  organizationSlug: "<org>",
  projectSlug: "<project>",
  query: "is:resolved lastSeen:>2026-03-10"
})
```

## Analysis Patterns

### Deploy Correlation

To correlate errors with a specific deploy:

```
1. Get deploy timestamp from .deploys/log.md or gh run list
2. Query issues with firstSeen after deploy:
   query: "is:unresolved firstSeen:><deploy-timestamp>"
3. These are candidate errors introduced by the deploy
4. Cross-reference with the code changed in that deploy:
   git diff <prev-sha>..<deploy-sha> --name-only
5. If changed files overlap with error stack trace → strong correlation
```

### Recurring Error Detection

```
1. Query all unresolved issues sorted by frequency
2. For each issue:
   a. Check .notebook/production/ for existing entry
   b. If documented and still occurring → update entry with new count
   c. If documented but count increasing → escalate severity
   d. If not documented and count > threshold → create new entry
```

Suggested thresholds:
- **Create notebook entry**: > 10 occurrences or > 5 affected users
- **Create Linear issue**: > 50 occurrences or > 20 affected users
- **Escalate to incident-response**: > 5% error rate or service degradation

### Error Rate Trend

```
1. Compare current error count with previous collection
   (stored in .notebook/production/health-baseline.md)
2. If error rate increased > 50% since last check → flag as HIGH
3. If error rate doubled → flag as CRITICAL
```

## Tool Availability

If the Sentry MCP is not authenticated or unavailable, the production-intelligence skill should:

1. Note: "Sentry MCP unavailable — error analysis skipped"
2. Continue with other sources (Portainer logs, health endpoints)
3. Suggest: "Set up Sentry with `observability-setup` for full production intelligence"

If specific Sentry tools are not available (the MCP may expose different tools depending on the Sentry plan), adapt queries to use whatever tools ARE available.
