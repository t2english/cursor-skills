---
name: coding-guidelines
description: Behavioral guidelines to reduce common LLM coding mistakes. Use when writing, modifying, or reviewing code — implementation tasks, code changes, refactoring, bug fixes, or feature development. Make sure to use this skill whenever the user asks to write code, change code, fix a bug, add a feature, refactor, or do any hands-on coding work, even if they don't mention "guidelines". Also use when reviewing pull requests or suggesting code improvements. Do NOT use for architecture design, documentation, or non-code tasks.
metadata:
  author: ale
  version: '1.0.0'
  source: 'Karpathy Guidelines'
---

# Coding Guidelines

Behavioral guidelines to reduce common LLM coding mistakes. These principles bias toward caution over speed—for trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:

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
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it—don't delete it.

When your changes create orphans:

- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

**The test:** Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## 5. Error Handling Strategy

**Fail fast, fail clearly. Never swallow errors silently.**

- Use custom error types/classes that carry context (not just messages)
- Errors should be actionable: include what went wrong AND what to do about it
- Never catch errors just to re-throw them without adding information
- Log errors at the boundary (API handler, queue consumer), not deep in business logic
- For async operations: always handle rejections, never leave promises unhandled

## 6. Accessibility and Internationalization

**When working on frontend code:**

- Use semantic HTML elements (`button`, `nav`, `main`) over generic `div`/`span`
- Include `aria-label` or `aria-describedby` for interactive elements without visible text
- Ensure keyboard navigation works (tab order, focus management)
- Use relative units (rem, em) over fixed pixels for font sizes
- Extract user-facing strings to constants or i18n files — never hardcode text in components
- Support RTL layouts if the project serves international users

## 7. When to Break the Rules

**Pragmatism over dogma. Rules serve the mission, not the other way around.**

These guidelines are defaults, not laws. Break them when:

- A deadline requires shipping "good enough" now (but leave a TODO with context)
- The existing codebase consistently does it differently (match the project, not the ideal)
- The rule creates more complexity than the problem it solves
- You're in a prototype/spike and clarity matters more than polish

When breaking a rule, state which rule and why: "Breaking simplicity-first here because [reason]."
