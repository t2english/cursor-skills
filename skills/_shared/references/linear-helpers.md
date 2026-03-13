# Linear Integration Helpers

Shared logic for skills that integrate with Linear MCP (server: `user-linear`).

Any skill that needs Linear integration should reference this file instead of duplicating logic.

## Prerequisites

Read `.cursor/linear.json` in the project root before any Linear operation:

```json
{
  "team": "<team name>",
  "teamId": "<uuid>",
  "project": "<project name>",
  "projectId": "<uuid>",
  "autoSync": { "tlcToLinear": true, "linearOnBranch": true, "sprintPlanning": true },
  "branchPattern": "(?:OKIA-)(\\d+)"
}
```

If the file doesn't exist, continue without Linear integration. Never fail the primary workflow because Linear is unavailable.

## Detect Issue from Branch

```
1. Get branch name: git branch --show-current
2. Apply branchPattern from config (regex match)
3. If match: search for issue
   CallMcpTool("user-linear", "list_issues", { team, query: "<matched-identifier>" })
4. If no match: search for issues In Progress assigned to me
   CallMcpTool("user-linear", "list_issues", { team, project, state: "In Progress", assignee: "me" })
5. If 1 result: use as current issue
6. If 0 or multiple: ask the developer
```

## Get Current Cycle

```
CallMcpTool("user-linear", "list_cycles", { teamId: "<teamId>", type: "current" })
```

## Update Issue Status

```
CallMcpTool("user-linear", "save_issue", { id: "<issue-id>", state: "<new-state>" })
```

Valid states: `Backlog`, `Todo`, `In Progress`, `In Review`, `Done`, `Canceled`

## Add Progress Comment

```
CallMcpTool("user-linear", "save_comment", {
  issueId: "<issue-id>",
  body: "## Progresso\n\n### Concluido\n- [summary]\n\n### Proximo\n- [next steps]"
})
```

## Graceful Degradation

All Linear operations are best-effort:
- If MCP is unavailable, skip silently and continue the primary workflow
- If `.cursor/linear.json` is missing, skip all Linear operations
- Never block or fail a development task because of Linear connectivity
- Log a brief note to the developer: "Linear integration skipped (config not found / MCP unavailable)"
