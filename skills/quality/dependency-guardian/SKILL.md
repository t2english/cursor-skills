---
name: dependency-guardian
description: Audit and manage project dependencies for security, licensing, and freshness. Detects vulnerabilities, outdated packages, license conflicts, and supply chain risks. Use when auditing dependencies, checking for vulnerabilities, updating packages, or configuring automated dependency management. Triggers on "audit dependencies", "check vulnerabilities", "update packages", "license check", "dependency health", "npm audit", "supply chain", "configure renovate", "configure dependabot". Do NOT use for general security reviews (use security-best-practices) or performance issues from dependencies (use performance-audit).
metadata:
  author: T2E
  version: "1.0.0"
---

# Dependency Guardian

Keep dependencies healthy: secure, licensed, and up to date.

## Step 1: Detect Package Ecosystem

```
1. package.json + lock file → npm/yarn/pnpm/bun
2. pyproject.toml / requirements.txt → pip/poetry/uv
3. go.mod → Go modules
4. Gemfile → bundler
5. Multiple ecosystems → audit each separately
```

## Step 2: Security Audit

Run the ecosystem's audit tool:

- **Node.js**: `npm audit` or `pnpm audit`
- **Python**: `pip audit` or `safety check`
- **Go**: `govulncheck ./...`

For each vulnerability found:
1. Severity (critical/high/medium/low)
2. Affected package and version
3. Fixed version (if available)
4. Is it a direct or transitive dependency?
5. Can it be patched without breaking changes?

Prioritize: critical direct dependencies first, then high, then transitive.

## Step 3: Outdated Analysis

Check for outdated packages:

- **Node.js**: `npm outdated` or `pnpm outdated`
- **Python**: `pip list --outdated`
- **Go**: `go list -m -u all`

Flag:
- Major version bumps (potential breaking changes — read changelogs)
- Packages with no updates in 2+ years (potential abandonment)
- Packages with known successors (moment → dayjs, request → got)

## Step 4: License Compliance

Verify license compatibility:

- **Permissive** (MIT, Apache-2.0, BSD): safe for commercial use
- **Copyleft** (GPL, AGPL): may require source disclosure — flag for review
- **No license**: legally risky — flag for replacement
- **Custom/proprietary**: requires legal review

Tools: `license-checker` (Node), `pip-licenses` (Python)

## Step 5: Supply Chain Health

Check indicators of supply chain risk:

- Lock file committed and up to date?
- Are there post-install scripts that execute code?
- Are critical dependencies from verified publishers?
- Is the package actively maintained (recent commits, responsive issues)?

## Step 6: Automated Management

Recommend and configure automated dependency updates:

**Renovate** (preferred — more configurable):
- Create `renovate.json` with appropriate presets
- Group minor/patch updates, individual PRs for major
- Auto-merge patch updates with passing CI

**Dependabot** (GitHub native):
- Create `.github/dependabot.yml`
- Configure update frequency and grouping

## Report Format

When producing a dependency health report:

```markdown
## Dependency Health Report

### Critical Vulnerabilities (N)
- [package@version] CVE-XXXX: description (fix: upgrade to version)

### Outdated (N major, N minor)
- [package] current → latest (breaking changes: yes/no)

### License Concerns (N)
- [package] License: GPL-3.0 (requires review)

### Recommendations
1. [Priority action]
2. [Secondary action]
```

## Integration

- **security-best-practices**: invokes this skill for dependency-level security
- **deploy-release**: pre-deploy dependency check
- **finalize-branch**: can include audit as pre-PR step
