---
name: coding-guidelines
description: Behavioral guidelines to reduce common LLM coding mistakes. Use when writing, modifying, or reviewing code — implementation tasks, code changes, refactoring, bug fixes, or feature development. Make sure to use this skill whenever the user asks to write code, change code, fix a bug, add a feature, refactor, or do any hands-on coding work, even if they don't mention "guidelines". Also use when reviewing pull requests or suggesting code improvements. Do NOT use for architecture design, documentation, or non-code tasks.
metadata:
  author: ale
  version: '1.1.0'
  source: 'Karpathy Guidelines'
---

# Coding Guidelines

Behavioral guidelines to reduce common LLM coding mistakes. These principles bias toward caution over speed—for trivial tasks, use judgment.

For the complete reference (12 sections including language best practices, dependencies, testing, comments, and more), read `_shared/references/coding-principles.md`.

Below is the quick-reference summary of the core principles.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

- State assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them—don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.
- Disagree honestly. If the user's approach seems wrong, say so—don't be sycophantic.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

- Don't "improve" adjacent code, comments, or formatting.
- Match existing style, even if you'd do it differently.
- Remove ONLY imports/variables/functions YOUR changes orphaned.

**The test:** Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

## 5. When to Break the Rules

Pragmatism over dogma. Break the rules when a deadline demands it, the codebase does it differently, or the rule adds more complexity than it solves. Always state which rule you're breaking and why.
