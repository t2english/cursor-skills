---
name: docs-writer
description: Write, review, and edit documentation files with consistent structure, tone, and technical accuracy. Supports 5 document types - API docs, ADRs, Changelogs, Runbooks, and READMEs. Use when creating docs, reviewing markdown files, writing READMEs, updating /docs directories, generating changelogs, recording architecture decisions, or writing operational runbooks. Triggers on "write documentation", "review this doc", "improve this README", "create a guide", "edit markdown", "write ADR", "generate changelog", "create runbook", "document this API". Do NOT use for code comments, inline JSDoc, or API reference auto-generation from code.
metadata:
  author: T2E
  version: "2.0.0"
---

# Docs Writer

Expert technical writer for producing and refining documentation. Accurate, clear, consistent, and easy to understand.

## Step 1: Identify Document Type

Determine which type of document is needed:

| Type | When to Use | Template |
|------|------------|----------|
| **API Documentation** | New or changed API endpoints | [api-docs.md](references/api-docs.md) |
| **ADR** | Architecture or design decision made | [adr-template.md](references/adr-template.md) |
| **Changelog** | Preparing a release | [changelog-format.md](references/changelog-format.md) |
| **Runbook** | Operational procedure needed | [runbook-template.md](references/runbook-template.md) |
| **README** | New project or major update | [readme-template.md](references/readme-template.md) |
| **General** | Guides, tutorials, reference docs | [style-guide.md](references/style-guide.md) |

## Step 2: Investigate and Gather

1. **Read the code**: Examine the relevant codebase to ensure documentation matches implementation.
2. **Check existing docs**: Read the latest version of related files before making changes.
3. **Verify connections**: If you change behavior docs, check for other pages that reference it. Keep links up to date.

## Step 3: Write or Edit

### Style Principles

- **Active voice**: "The service validates tokens" not "Tokens are validated by the service"
- **Present tense**: "Returns a list" not "Will return a list"
- **Concrete over abstract**: Show examples, not just descriptions
- **Scannable**: Use headers, lists, tables. Walls of text lose readers.
- **Minimal jargon**: Define terms on first use. Assume a competent developer, not a domain expert.
- **No filler**: Cut "basically", "simply", "just", "actually", "in order to"

### API Documentation Workflow

When documenting API endpoints:

1. List all endpoints (method, path, description)
2. For each endpoint: request format, response format, error codes, auth requirements
3. Include curl/fetch examples for common operations
4. Document rate limits, pagination, and versioning if applicable
5. If the project uses OpenAPI/Swagger, update the spec file alongside prose docs

### ADR (Architecture Decision Record) Workflow

When a design decision is made (especially during spec-driven DESIGN phase):

1. Use the template: Title, Date, Status, Context, Decision, Consequences
2. Explain the alternatives considered and why they were rejected
3. Document constraints that influenced the decision
4. Link to related ADRs if they exist
5. Store in `docs/adr/` with sequential numbering: `0001-use-postgres.md`

### Changelog Workflow

When preparing a release:

1. Gather commits since last tag: `git log --oneline <last-tag>..HEAD`
2. Group by type using conventional commits: Added, Changed, Fixed, Removed, Security
3. Write human-readable summaries (not raw commit messages)
4. Include breaking changes prominently at the top
5. Follow Keep a Changelog format (keepachangelog.com)

### Runbook Workflow

When documenting an operational procedure:

1. Title: what this runbook is for
2. When to use: specific symptoms or triggers
3. Prerequisites: access, tools, permissions needed
4. Steps: numbered, specific, copy-pasteable commands
5. Verification: how to confirm each step worked
6. Rollback: how to undo if something goes wrong
7. Contacts: who to escalate to

### README Workflow

For new projects or major updates:

1. Project name and one-line description
2. Quick start (3-5 steps to get running)
3. Architecture overview (brief, with diagram if complex)
4. Development setup (prerequisites, install, run, test)
5. Deployment (how to deploy, environments)
6. Contributing (branch naming, PR process, code style)

## Step 4: Verify

1. Re-read all changes for accuracy against the code
2. Verify all links (internal and external)
3. Check formatting renders correctly in markdown
4. If the project has a formatting script, offer to run it

## Integration with Other Skills

- **spec-driven**: When a design decision is made, suggest creating an ADR
- **deploy-release**: Invoke changelog workflow before releases
- **finalize-branch**: Documentation updates should be part of the PR
