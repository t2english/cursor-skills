# Coding Principles

Canonical source of coding principles shared across skills.
Read this file during implementation. These principles reduce common AI coding mistakes.

## 1. Think Before Coding

Before writing any code:

- State your assumptions explicitly. If uncertain, ask.
- If multiple approaches exist, present them with tradeoffs.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.
- If the developer's approach seems wrong, say so constructively.
  Don't be sycophantic — honesty prevents bugs.

## 2. Simplicity First

Write the minimum code that solves the problem.

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- No speculative optimization.
- If you wrote 200 lines and it could be 50, rewrite it.

The test: "Would a senior engineer say this is overcomplicated?"
If yes, simplify.

## 3. Surgical Changes

When editing existing code:

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated issues, mention them — don't fix them.

When your changes create orphans:

- Remove imports, variables, and functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line traces directly to the mission objective.

## 4. Goal-Driven Execution

Transform vague tasks into verifiable goals:

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan with verification checkpoints.
Strong success criteria enable autonomous execution. Weak criteria
("make it work") require constant clarification — ask for better
criteria rather than guessing.

## 5. Respect the Codebase

You are a guest in this codebase. Act like it.

- Use the same naming conventions already in the project.
- Use the same file organization patterns.
- Use the same error handling approach.
- Use the same import style (named vs default, relative vs absolute).
- If the project uses semicolons, use semicolons. If it doesn't, don't.

If existing conventions conflict with language best practices, flag it
to the developer. Don't silently introduce a different convention.

## 6. Language Best Practices

Always follow the official best practices for the language and
frameworks in use. This means:

- Use idiomatic patterns for the language (e.g., list comprehensions
  in Python, Optional chaining in TypeScript).
- Follow the official style guide when the project doesn't have its own.
- Use current, non-deprecated APIs and methods.
- Handle errors according to the language's conventions (try/catch,
  Result types, error returns — whatever the ecosystem prefers).

Critical: Never rely on training memory for API signatures, method
parameters, or framework behavior. Always verify against current
documentation using the Knowledge Verification Chain:

```
.notebook/ → project docs → MCP Context7 → web search → flag as uncertain
```

## 7. Dependencies and Imports

When adding new dependencies or imports:

- Check if the project already has a dependency that solves the
  problem before adding a new one.
- Check the project's package manager and lockfile for existing
  versions.
- If adding a new dependency, mention it to the developer with
  rationale — never silently add packages.
- Match the project's import style and ordering conventions.

## 8. Error Handling

- Handle errors that can realistically occur.
- Don't add catch blocks for theoretically impossible scenarios.
- Use custom error types/classes that carry context (not just messages).
- Errors should be actionable: include what went wrong AND what to do about it.
- Never catch errors just to re-throw them without adding information.
- Log errors at the boundary (API handler, queue consumer), not deep in business logic.
- For async operations: always handle rejections, never leave promises unhandled.
- Never swallow errors silently (empty catch blocks) unless
  there's an explicit reason documented in a comment.

## 9. Testing

When tests are part of the mission:

- Write tests that verify behavior, not implementation details.
- Test the contract (input → output), not internal state.
- Name tests descriptively: "should reject expired coupon"
  not "test1" or "coupon test."
- If modifying existing code, run existing tests first to
  establish a baseline.
- If adding a bug fix, write a test that reproduces the bug
  first, then fix it.

When tests are NOT part of the mission:

- Don't add tests unless asked.
- But DO mention if the change is risky and untested:
  "This change affects the payment flow but there are no tests
  covering this path. Consider adding tests for [specific cases]."

## 10. Comments

- Don't add comments that restate the code.
- Don't remove existing comments unless they're provably wrong.
- Add comments only for non-obvious business logic or workarounds.
- If you add a workaround, explain WHY it's necessary and link
  to the relevant issue/ticket if available.
- Match the project's commenting style and language (human language).

## 11. Accessibility and Internationalization

When working on frontend code:

- Use semantic HTML elements (`button`, `nav`, `main`) over generic `div`/`span`.
- Include `aria-label` or `aria-describedby` for interactive elements without visible text.
- Ensure keyboard navigation works (tab order, focus management).
- Use relative units (rem, em) over fixed pixels for font sizes.
- Extract user-facing strings to constants or i18n files — never hardcode text in components.
- Support RTL layouts if the project serves international users.

## 12. When to Break the Rules

These principles are defaults, not laws. Break them when:

- A deadline requires shipping "good enough" now (but leave a TODO with context).
- The existing codebase consistently does it differently (match the project, not the ideal).
- The rule creates more complexity than the problem it solves.
- You're in a prototype/spike and clarity matters more than polish.

When breaking a rule, state which rule and why: "Breaking simplicity-first here because [reason]."
