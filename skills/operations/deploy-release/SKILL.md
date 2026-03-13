---
name: deploy-release
description: End-to-end workflow for deploying applications and managing releases. Covers pre-deploy checklists, release notes generation, versioning, rollback procedures, and post-deploy verification. Stack-agnostic with strategy guides for common platforms. Use when deploying to staging or production, creating releases, generating release notes, or planning rollback procedures. Triggers on "deploy", "release", "ship it", "push to production", "create release", "rollback", "release notes", "pre-deploy check". Do NOT use for CI debugging (use gh-fix-ci) or branch management (use finalize-branch).
metadata:
  author: T2E
  version: "1.0.0"
---

# Deploy & Release

Disciplined deployment workflow. No YOLO pushes to production.

## Pre-Deploy Checklist

Before any deployment, verify:

```
1. All tests passing: <package-manager> test
2. Build succeeds: <package-manager> build
3. No pending migrations:
   - Check for new migration files not yet applied
   - If ORM detected (Prisma, Drizzle, TypeORM), check migration status
4. Environment variables:
   - Compare .env.example with target environment
   - Flag any new vars added since last deploy
5. Dependencies:
   - No known security vulnerabilities (invoke dependency-guardian if available)
   - Lock file is committed and up to date
6. Changelog:
   - Release notes generated (invoke docs-writer if available)
7. Linear status:
   - All issues for this release are in "Done" or "In Review"
   - See _shared/references/linear-helpers.md for integration
```

## Release Notes Generation

Generate notes from conventional commits since last tag:

```
1. Find last tag: git describe --tags --abbrev=0
2. Gather commits: git log --oneline <last-tag>..HEAD
3. Group by prefix:
   - feat: → Added
   - fix: → Fixed
   - perf: → Performance
   - BREAKING CHANGE: → Breaking Changes (top of notes)
   - chore/refactor/docs: → Maintenance
4. Write human-readable summaries
5. Include contributors if multiple authors
```

## Versioning (Semver)

```
MAJOR.MINOR.PATCH

- MAJOR: breaking changes (API contracts change, removed features)
- MINOR: new features (backward compatible)
- PATCH: bug fixes (backward compatible)
```

When releasing:
```bash
# Bump version (auto-detects from commits if using conventional commits)
npm version <major|minor|patch>
# Or manual: edit package.json/pyproject.toml + git tag
git tag -a v<version> -m "Release v<version>"
git push origin v<version>
```

## Deploy Strategies

Detect the target platform and follow the appropriate strategy:

**Vercel/Netlify** (auto-deploy from git):
- Merge to main triggers deploy automatically
- Verify via deployment URL in PR checks
- Rollback: revert commit or use platform dashboard

**Docker**:
- Build image: `docker build -t <app>:<version> .`
- Push to registry: `docker push <registry>/<app>:<version>`
- Update deployment (K8s, ECS, Docker Compose)
- Rollback: deploy previous image tag

**Manual/SSH**:
- Document exact commands in a runbook (invoke docs-writer)
- Always test on staging first
- Keep a rollback script ready

## Rollback Procedure

If something goes wrong after deploy:

```
1. IMMEDIATE: Is production broken? If yes, rollback NOW, investigate later.
2. Rollback options (fastest first):
   a. Feature flag: disable the feature (if available)
   b. Revert deploy: deploy the previous version/image/commit
   c. Git revert: create a revert commit and re-deploy
3. After rollback:
   - Verify production is stable
   - Create incident issue in Linear (invoke incident-response if available)
   - Investigate root cause on a branch, not in production
```

## Post-Deploy Verification

After deploying:

```
1. Health check: hit /health or /ready endpoint
2. Smoke test: verify critical user flows work
3. Monitor error rate: check Sentry/logs for new errors (first 15 minutes)
4. Update Linear: move issues to "Done" (see _shared/references/linear-helpers.md)
5. Announce: notify team in appropriate channel
```

## Integration

- **finalize-branch**: merges the code; this skill handles what comes after
- **docs-writer**: generates changelogs and release notes
- **incident-response**: invoked if deploy causes issues
- **linear-project-management**: updates issue status post-deploy
- **dependency-guardian**: pre-deploy vulnerability check
