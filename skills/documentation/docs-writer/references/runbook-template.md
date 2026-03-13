# Runbook Template

Use this template when documenting operational procedures. Runbooks should be
actionable during an incident — clear, step-by-step, with copy-pasteable commands.

## Template

```markdown
# Runbook: <Procedure Title>

**Last updated**: YYYY-MM-DD
**Owner**: <team or person>

## When to Use

<Describe the specific symptoms, alerts, or triggers that indicate this
runbook should be followed. Be concrete — "Sentry alert: DatabaseConnectionExhausted
fires more than 5 times in 10 minutes.">

## Prerequisites

- [ ] Access to <system/service>
- [ ] <Tool> installed and configured
- [ ] Permissions: <specific role or access level>

## Steps

### 1. <Action title>

<Brief explanation of what this step does and why.>

```bash
<copy-pasteable command>
```

**Expected output**: <what you should see if it worked>

**If it fails**: <what to do if this step doesn't work>

### 2. <Action title>

...

### 3. <Action title>

...

## Verification

After completing all steps, verify the fix:

1. <How to confirm the issue is resolved>
2. <What metrics/logs to check>
3. <How long to monitor before declaring success>

## Rollback

If the procedure makes things worse:

1. <Step to undo the change>
2. <How to verify the rollback worked>
3. <When to escalate>

## Escalation

If this runbook does not resolve the issue:

| Contact    | Channel        | When to escalate              |
|------------|----------------|-------------------------------|
| <Name>     | <Slack/phone>  | <Specific condition>          |
| <On-call>  | <PagerDuty>    | <Service still down after N>  |

## History

| Date       | Author | Change                        |
|------------|--------|-------------------------------|
| YYYY-MM-DD | <name> | Created                       |
| YYYY-MM-DD | <name> | Updated step 3 for new config |
```

## Guidelines

- **Copy-pasteable commands**: Every command should work when pasted directly.
  Use full paths, avoid aliases. Include environment-specific placeholders
  clearly marked with `<angle-brackets>`.
- **Expected output**: After each command, describe what success looks like.
  This prevents operators from proceeding on a failed step.
- **Failure paths**: For each step, briefly describe what to do if it fails.
- **No assumptions**: Don't assume the reader knows the system. Include
  context like which server to SSH into, which dashboard to check.
- **Time estimates**: If a step takes time (e.g., "wait 5 minutes for
  containers to restart"), say so explicitly.
- **Test periodically**: Runbooks go stale. Review and test them at least
  once per quarter.
