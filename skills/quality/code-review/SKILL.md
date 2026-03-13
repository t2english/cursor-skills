---
name: code-review
description: Proactive pre-PR code review that catches issues before they reach teammates. Checks naming, patterns, security flags, test coverage delta, complexity, and project conventions. Configurable via .cursor/review.json. Use when about to create a PR, when asked to review code, or as a pre-flight check before pushing. Triggers on "review this code", "review before PR", "pre-flight check", "check my code", "is this ready for PR". Do NOT use for responding to existing PR comments (use gh-address-comments) or for CI failures (use gh-fix-ci).
metadata:
  author: T2E
  version: "1.0.0"
---

# Code Review

Proactive review that catches issues before they reach your team. Think of this as your pre-flight checklist before takeoff.

## When to Review

- Before creating a PR (called by `finalize-branch` if available)
- When the developer asks "is this ready?"
- After completing a significant implementation

## Review Workflow

### Step 1: Gather Context

```
1. Get changed files: git diff --name-only main..HEAD
2. Get full diff: git diff main..HEAD
3. Read .cursor/review.json if it exists (custom checklist)
4. Count: files changed, lines added/removed, new files
```

### Step 2: Run Automated Checks

If the project has configured checks, run them:

```
1. Linter: <detected-lint-command>
2. Type checker: <detected-typecheck-command>
3. Tests: <detected-test-command>
```

Report any failures before proceeding to manual review.

### Step 3: Review Checklist

Evaluate each changed file against these categories:

#### Correctness
- Does the logic match the intended behavior?
- Are edge cases handled (null, empty, boundary values)?
- Are error paths handled appropriately?
- Are async operations properly awaited?

#### Naming and Clarity
- Do variable/function names describe what they do?
- Are there abbreviations that hurt readability?
- Is the code self-documenting or does it need comments for non-obvious logic?

#### Patterns and Consistency
- Does new code match existing project patterns?
- Are there patterns used elsewhere that should be followed here?
- Is there duplicated logic that should reference shared code?

#### Security Flags
- Hardcoded secrets, API keys, tokens?
- User input used without sanitization?
- SQL/NoSQL injection vectors?
- Overly permissive CORS or auth rules?

#### Test Coverage
- Do new files have corresponding test files?
- Do new functions with logic have tests?
- Are edge cases from the code reflected in tests?

#### Complexity
- Functions longer than ~30 lines (suggest extraction)
- Nesting deeper than 3 levels (suggest early returns)
- Files with too many responsibilities (suggest splitting)

### Step 4: Produce Findings Report

Categorize findings:

- **Critical**: Must fix before merge (bugs, security, data loss risk)
- **Warning**: Should fix, creates tech debt (missing tests, complexity)
- **Suggestion**: Nice to have, improve quality (naming, patterns)
- **Praise**: Highlight good patterns to reinforce them

Format:

```
## Review Summary

Files reviewed: N | Lines changed: +X/-Y

### Critical (N)
- [file:line] Description of issue

### Warning (N)
- [file:line] Description of issue

### Suggestion (N)
- [file:line] Description of suggestion

### Good patterns spotted
- [file] Description of good practice
```

### Step 5: Offer Fixes

For each Critical and Warning finding, offer to fix it:

"I found N critical and M warning issues. Want me to fix them before the PR?"

Apply fixes surgically — only address the specific findings.

## Custom Checklist

Projects can configure a `.cursor/review.json`:

```json
{
  "checks": {
    "maxFunctionLength": 30,
    "maxNestingDepth": 3,
    "requireTestsForNewFiles": true,
    "securityScan": true,
    "namingConvention": "camelCase"
  },
  "ignore": [
    "**/*.generated.ts",
    "**/migrations/**"
  ]
}
```

If the file doesn't exist, use sensible defaults.

## Integration

- **finalize-branch**: calls this skill as a pre-flight step before creating PR
- **testing-strategy**: invoked when test coverage issues are found
- **security-best-practices**: invoked when security flags are found
