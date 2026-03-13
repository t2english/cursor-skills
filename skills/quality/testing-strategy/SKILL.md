---
name: testing-strategy
description: Dedicated workflow for creating, running, and analyzing tests across all levels (unit, integration, e2e). Auto-detects the project's testing framework, provides templates by test type, and analyzes coverage gaps. Use when writing tests, improving coverage, setting up test infrastructure, or validating implementations. Triggers on "write tests", "add tests", "test this", "improve coverage", "testing strategy", "what should I test", "set up testing". Do NOT use for debugging test failures in CI (use gh-fix-ci) or for running tests as part of branch finalization (use finalize-branch).
metadata:
  author: T2E
  version: "1.0.0"
---

# Testing Strategy

Systematic approach to testing that ensures quality without over-testing. Right tests, right level, right coverage.

## Framework Detection

Before writing any test, detect the project's testing setup:

```
1. Check package.json / pyproject.toml / go.mod for test dependencies
2. Look for existing test files to understand patterns:
   - **/*.test.{ts,tsx,js} or **/*.spec.{ts,tsx,js} → vitest/jest
   - **/test_*.py or **/*_test.py → pytest
   - **/*_test.go → go test
   - **/e2e/** or **/cypress/** → cypress/playwright
3. Check for test config files: vitest.config.ts, jest.config.js, pytest.ini, playwright.config.ts
4. Read 1-2 existing test files to learn the project's test patterns and conventions
```

If no test infrastructure exists, recommend setup before writing tests.

## The Testing Pyramid

Allocate effort according to the pyramid:

```
        /  E2E  \        ← Few: critical user flows only
       / Integration \    ← Some: module boundaries, API contracts
      /     Unit       \  ← Many: business logic, pure functions
```

**Unit tests** (70% of effort): Fast, isolated, test one thing. Mock external deps.
**Integration tests** (20%): Test module boundaries. Real DB/API where practical.
**E2E tests** (10%): Critical user journeys only. Expensive to maintain.

## Workflow: Writing Tests

### Step 1: Identify What to Test

Ask: "What behavior matters here?"

- **Functions with logic**: conditionals, transformations, calculations
- **Edge cases**: null/undefined, empty arrays, boundary values
- **Error paths**: invalid input, network failures, permission denied
- **Integration points**: API responses, database queries, external services

Do NOT test:
- Simple getters/setters with no logic
- Framework internals (React rendering, Express routing)
- Configuration files
- Third-party library behavior

### Step 2: Follow Project Conventions

Match existing test patterns exactly:
- File location (co-located vs `__tests__/` directory)
- Naming (`describe`/`it` vs `test`, naming style)
- Setup/teardown patterns
- Mock/stub approach
- Assertion style

### Step 3: Write Tests Using AAA Pattern

```
Arrange → Act → Assert
```

Each test should:
- Have a descriptive name that explains the behavior being tested
- Test ONE behavior per test case
- Be independent (no shared mutable state between tests)
- Run fast (mock slow dependencies)

### Step 4: Verify

```bash
# Run tests (detect command from package.json scripts or project conventions)
<package-manager> test

# Run with coverage
<package-manager> test -- --coverage
```

## Workflow: Coverage Analysis

When asked to analyze or improve coverage:

```
1. Run coverage: <package-manager> test -- --coverage
2. Identify uncovered files/functions with business logic
3. Prioritize by risk:
   - High: payment, auth, data mutation → must cover
   - Medium: API endpoints, services → should cover
   - Low: utilities, helpers, config → nice to have
4. Suggest specific tests for the highest-risk uncovered code
5. Do NOT chase 100% — aim for meaningful coverage of critical paths
```

## Workflow: Test-Driven Bug Fix

When fixing a bug, always start with a test:

```
1. Write a failing test that reproduces the bug
2. Verify it fails for the right reason
3. Fix the code
4. Verify the test passes
5. Check no other tests broke
```

## Integration with Other Skills

- **code-navi** VERIFY step: invoke this skill to validate test coverage for changed files
- **finalize-branch**: checks that tests pass before PR
- **code-review**: flags new files without corresponding test files

## Anti-Patterns to Avoid

- Testing implementation details instead of behavior
- Snapshot tests for everything (brittle, low signal)
- Mocking everything (tests that test nothing)
- Test files that are longer than the code they test
- Ignoring flaky tests instead of fixing them
- Writing tests after the fact without understanding intent
