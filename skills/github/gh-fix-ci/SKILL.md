---
name: gh-fix-ci
description: Debug and fix failing GitHub PR checks that run in GitHub Actions. Uses `gh` to inspect checks and logs, summarize failure context, draft a fix plan, and implement only after explicit approval. Use whenever the user mentions CI failures, broken pipeline, red checks, failing tests in CI, GitHub Actions errors, "CI is broken", "checks are failing", "fix the pipeline", or any PR check that isn't passing. Treats external providers (e.g. Buildkite) as out of scope. Do NOT use for addressing PR review comments (use gh-address-comments) or general CI outside GitHub Actions.
metadata:
  author: github.com/openai/skills
  version: '1.1.0'
---

# GitHub Fix CI

## Overview

Use gh to locate failing PR checks, fetch GitHub Actions logs for actionable failures, summarize the failure snippet, then propose a fix plan and implement after explicit approval.

- If a plan-oriented skill (for example `create-plan`) is available, use it; otherwise draft a concise plan inline and request approval before implementing.

Prereq: authenticate with the standard GitHub CLI once (for example, run `gh auth login`), then confirm with `gh auth status` (repo + workflow scopes are typically required).

## Inputs

- `repo`: path inside the repo (default `.`)
- `pr`: PR number or URL (optional; defaults to current branch PR)
- `gh` authentication for the repo host

## Quick start

- `python "<path-to-skill>/scripts/inspect_pr_checks.py" --repo "." --pr "<number-or-url>"`
- Add `--json` if you want machine-friendly output for summarization.

## Workflow

1. Verify gh authentication.
   - Run `gh auth status` in the repo.
   - If unauthenticated, ask the user to run `gh auth login` (ensuring repo + workflow scopes) before proceeding.
2. Resolve the PR.
   - Prefer the current branch PR: `gh pr view --json number,url`.
   - If the user provides a PR number or URL, use that directly.
3. Inspect failing checks (GitHub Actions only).
   - Preferred: run the bundled script (handles gh field drift and job-log fallbacks):
     - `python "<path-to-skill>/scripts/inspect_pr_checks.py" --repo "." --pr "<number-or-url>"`
     - Add `--json` for machine-friendly output.
   - Manual fallback:
     - `gh pr checks <pr> --json name,state,bucket,link,startedAt,completedAt,workflow`
       - If a field is rejected, rerun with the available fields reported by `gh`.
     - For each failing check, extract the run id from `detailsUrl` and run:
       - `gh run view <run_id> --json name,workflowName,conclusion,status,url,event,headBranch,headSha`
       - `gh run view <run_id> --log`
     - If the run log says it is still in progress, fetch job logs directly:
       - `gh api "/repos/<owner>/<repo>/actions/jobs/<job_id>/logs" > "<path>"`
4. Scope non-GitHub Actions checks.
   - If `detailsUrl` is not a GitHub Actions run, label it as external and only report the URL.
   - Do not attempt Buildkite or other providers; keep the workflow lean.
5. Summarize failures for the user.
   - Provide the failing check name, run URL (if any), and a concise log snippet.
   - Call out missing logs explicitly.
6. Create a plan.
   - Use the `create-plan` skill to draft a concise plan and request approval.
7. Implement after approval.
   - Apply the approved plan, summarize diffs/tests, and ask about opening a PR.
8. Recheck status.
   - After changes, suggest re-running the relevant tests and `gh pr checks` to confirm.

## Bundled Resources

### scripts/inspect_pr_checks.py

Fetch failing PR checks, pull GitHub Actions logs, and extract a failure snippet. Exits non-zero when failures remain so it can be used in automation.

Usage examples:

- `python "<path-to-skill>/scripts/inspect_pr_checks.py" --repo "." --pr "123"`
- `python "<path-to-skill>/scripts/inspect_pr_checks.py" --repo "." --pr "https://github.com/org/repo/pull/123" --json`
- `python "<path-to-skill>/scripts/inspect_pr_checks.py" --repo "." --max-lines 200 --context 40`

## Common Fix Patterns

Reference for the most common CI failures and their fixes:

### Lockfile Sync
**Symptom**: "lockfile is out of sync" or "missing dependencies"
**Fix**: Run `<package-manager> install` from repo root and commit the updated lock file.

### Type Errors
**Symptom**: TypeScript compilation fails with type errors
**Fix**: Check if types are from a recently updated dependency. May need `@types/` package update.

### Flaky Tests
**Symptom**: Test passes locally but fails in CI (or fails intermittently)
**Indicators**: Different results on re-run, timing-dependent assertions, external API calls
**Fix**: Add retries for network-dependent tests, use fixed timestamps in date tests, mock external services.

### Missing Environment Variables
**Symptom**: "undefined" errors or config validation failures
**Fix**: Check CI workflow secrets/variables. Add missing vars to GitHub Actions secrets.

### Timeout
**Symptom**: Job exceeds time limit
**Fix**: Check for infinite loops, increase timeout if test suite grew, optimize slow tests.

## Failure Categories

When reporting failures, classify them:

- **build**: Compilation/transpilation errors (TypeScript, ESBuild, etc.)
- **lint**: Code style and static analysis violations
- **test**: Test assertions failing
- **integration**: Integration/E2E test failures
- **timeout**: Job exceeded time limit
- **infra**: CI infrastructure issues (runner unavailable, network, permissions)

## Rerun Strategy

Before fixing, determine if a rerun might resolve it:

```
1. Is this a known flaky test? → rerun: gh run rerun <run-id> --failed
2. Is this an infra issue (network, runner)? → rerun the failed jobs only
3. Is this a code issue? → fix the code, don't rerun
```
