# ADR (Architecture Decision Record) Template

Use this template when recording architecture or design decisions. Store ADRs in
`docs/adr/` with sequential numbering: `0001-short-title.md`.

## Template

```markdown
# <NUMBER>. <Title>

**Date**: YYYY-MM-DD
**Status**: Proposed | Accepted | Deprecated | Superseded by [ADR-XXXX](XXXX-title.md)

## Context

<What is the issue or situation that motivates this decision? Include relevant
constraints, requirements, and forces at play. Describe the problem, not the
solution.>

## Decision

<What is the change that we are proposing or have agreed to implement? State
the decision clearly and concisely.>

## Alternatives Considered

### <Alternative 1>

- **Pros**: ...
- **Cons**: ...
- **Why rejected**: ...

### <Alternative 2>

- **Pros**: ...
- **Cons**: ...
- **Why rejected**: ...

## Consequences

### Positive

- <Benefit 1>
- <Benefit 2>

### Negative

- <Tradeoff 1>
- <Tradeoff 2>

### Risks

- <Risk and mitigation strategy>

## References

- <Links to related ADRs, RFCs, documentation, or discussions>
```

## Guidelines

- **One decision per ADR**: Keep each record focused on a single decision.
- **Immutable once accepted**: Don't edit accepted ADRs. Supersede them with a
  new ADR that references the old one.
- **Context over conclusion**: Spend more words on Context than Decision. Future
  readers need to understand WHY, not just WHAT.
- **Include rejected alternatives**: This prevents revisiting the same options.
- **Link related ADRs**: If this decision depends on or supersedes another,
  reference it explicitly.

## Status Lifecycle

```
Proposed → Accepted → (optionally) Deprecated or Superseded
```

- **Proposed**: Under discussion, not yet agreed.
- **Accepted**: Team has agreed to implement this decision.
- **Deprecated**: No longer relevant (technology removed, requirement changed).
- **Superseded**: Replaced by a newer ADR (link to the replacement).
