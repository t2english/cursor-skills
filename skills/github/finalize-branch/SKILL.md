---
name: finalize-branch
description: Finalize current branch following git best practices - lint, knip, build, test, push, PR, CI, merge, cleanup. Use when the user says "finalize branch", "close branch", "merge branch", "create PR", "push and merge", "ship it", "done with this feature", "ready to merge", or after completing a feature/fix and the next logical step is pushing and merging. Also use when the user asks to run the full pre-merge pipeline or prepare a branch for review. Do NOT use for creating new branches or starting new work. Detects package manager automatically and supports configurable checks.
---

# Finalize Branch

Complete workflow to close a branch following project conventions.

## Prerequisites

- Working tree must be clean (all changes committed)
- Branch must follow naming convention: `<type>/<description>`

## Configuration

This skill auto-detects project settings. Optionally configure via `.cursor/finalize.json`:

```json
{
  "checks": ["lint", "typecheck", "test"],
  "mergeStrategy": "squash",
  "requireReview": true
}
```

If the file doesn't exist, defaults are used: lint + build + test, squash merge.

## Steps

### 1. Verify State

```bash
git status          # must be clean
git branch --show-current  # confirm branch name
git log --oneline main..HEAD  # review commits to be merged
```

### 1.5. Detect Linear Issue

If `.cursor/linear.json` exists, find the associated issue using the shared helper.

See `_shared/references/linear-helpers.md` → "Detect Issue from Branch" for the full procedure.

Store the issue ID for steps 3 and 5. If no issue found or Linear MCP unavailable, continue without Linear updates.

### 2. Detect Package Manager and Run Checks

Auto-detect package manager from lock files:

```
pnpm-lock.yaml → pnpm
yarn.lock      → yarn
bun.lockb      → bun
package-lock.json → npm
requirements.txt / pyproject.toml → pip/poetry
go.mod         → go
```

Run checks in sequence (read from `.cursor/finalize.json` if exists, otherwise use defaults):

```bash
<pm> lint        # Linter
<pm> build       # Compilation/build
<pm> test        # Unit tests
```

If any fail, fix before continuing.

### 2.5. Pre-flight Code Review

If the `code-review` skill is available, invoke it before creating the PR:

```
1. Run code-review pre-flight check on changed files
2. If critical findings: fix before continuing
3. If warnings only: include in PR description as "Known issues"
```

If code-review is not available, skip this step.

### 3. Push and Create PR

```bash
git push -u origin <branch-name>
gh pr create --base main --title "<conventional commit title>" --body "<summary>"
```

PR body should include:
- Summary (bullet points of changes)
- Test plan (what was tested)
- Reference to Linear issue if applicable

**Update Linear**: If issue was detected, update status to "In Review" and add PR link as comment. See `_shared/references/linear-helpers.md`.

### 4. Monitor CI

```bash
gh pr checks <pr-number>   # poll until all pass
```

CI jobs: validate-lockfile -> lint + knip + typecheck + tests + integration -> coverage -> build-check -> status

### 5. Merge (when CI is green)

```bash
gh pr merge <pr-number> --squash --delete-branch
```

Use `--squash` for feature/fix branches (clean single commit on main).

**Update Linear**: If issue was detected, update status to "Done" and add summary comment. See `_shared/references/linear-helpers.md`.

### 6. Cleanup

```bash
git checkout main
git pull origin main
git branch -d <branch-name>   # delete local if not auto-deleted
```

### 6.5. Workspace Sweep (optional)

If the `workspace-hygiene` skill is available, suggest a Quick Sweep:

> "Feature merged. Want me to archive the specs and clean up artifacts for this feature?"

If the developer accepts, invoke `workspace-hygiene` Quick Sweep with the feature name derived from the merged branch. If declined or skill unavailable, skip.

## Important Notes

- NEVER merge with failing CI
- NEVER force push to main
- If CI fails, fix on the same branch, push again, CI re-runs automatically
- Lockfile sync issues: run `pnpm install` from repo root and commit the updated lockfile
- **Se nao tiver certeza** do comando, do package manager ou do contexto (repo, branch base), **pergunte ao usuario** antes de executar. Adapte os passos ao projeto (ex.: npm/yarn em vez de pnpm).
