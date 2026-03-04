---
name: finalize-branch
description: Finalize current branch following git best practices - lint, knip, build, test, push, PR, CI, merge, cleanup. Use when user says "finalize branch", "close branch", "merge branch", "create PR", "push and merge", or after completing a feature/fix. Do NOT use for creating new branches or starting new work.
---

# Finalize Branch

Complete workflow to close a branch following project conventions.

## Prerequisites

- Working tree must be clean (all changes committed)
- Branch must follow naming convention: `<type>/<description>`

## Steps

### 1. Verify State

```bash
git status          # must be clean
git branch --show-current  # confirm branch name
git log --oneline main..HEAD  # review commits to be merged
```

### 2. Run Local Checks

Run in sequence from `okia-swarm/`:

```bash
pnpm lint       # ESLint
pnpm knip       # Dead code, unused deps/files
pnpm build      # TypeScript compilation
pnpm test       # Unit tests
```

If any fail, fix before continuing.

### 3. Push and Create PR

```bash
git push -u origin <branch-name>
gh pr create --base main --title "<conventional commit title>" --body "<summary>"
```

PR body should include:
- Summary (bullet points of changes)
- Test plan (what was tested)
- Reference to Linear issue if applicable

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

### 6. Cleanup

```bash
git checkout main
git pull origin main
git branch -d <branch-name>   # delete local if not auto-deleted
```

## Important Notes

- NEVER merge with failing CI
- NEVER force push to main
- If CI fails, fix on the same branch, push again, CI re-runs automatically
- Lockfile sync issues: run `pnpm install` from repo root and commit the updated lockfile
- **Se nao tiver certeza** do comando, do package manager ou do contexto (repo, branch base), **pergunte ao usuario** antes de executar. Adapte os passos ao projeto (ex.: npm/yarn em vez de pnpm).
