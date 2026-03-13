---
name: workspace-hygiene
description: Clean up and archive development artifacts after features are completed. Two modes - Quick Sweep (light, post-merge) archives completed feature specs, removes stale plans and handoff files; Deep Clean (thorough, per-sprint) prunes old archives, detects orphan files, and cleans stale branches. Use when the workspace has accumulated artifacts from completed work, during sprint retrospectives, or after merging a feature. Triggers on "clean up", "workspace hygiene", "archive specs", "clean workspace", "prune", "housekeeping", "remove old plans", "deep clean", "sweep", "tidy up". Do NOT use for git branch cleanup alone (use finalize-branch) or for .notebook/ curation (handled by code-navi automatically).
metadata:
  author: T2E
  version: "1.0.0"
---

# Workspace Hygiene

Keep the workspace clean. Archive what's done, prune what's stale, delete what's dead.

## Principles

1. **Never delete without asking** — always list what will be removed and wait for confirmation
2. **Archive first, delete later** — move to `_archive/` first; suggest deletion only after 90 days
3. **Graceful degradation** — if `.specs/` doesn't exist, skip; if `.notebook/` doesn't exist, skip
4. **Configurable** — respect `.cursor/hygiene.json` if it exists

## Configuration

Optional `.cursor/hygiene.json`:

```json
{
  "archiveAfterDays": 0,
  "pruneAfterDays": 90,
  "exclude": ["important-feature"],
  "autoSweepOnMerge": true
}
```

If the file doesn't exist, defaults are used: archive immediately on sweep, prune after 90 days.

## Mode 1: Quick Sweep

Light cleanup after a feature is completed. Triggered by `finalize-branch` after merge, by `feature-lifecycle` after MONITOR, or manually.

### Trigger

- User says "clean up", "sweep", "archive specs"
- Invoked by `finalize-branch` after step 6 (Cleanup)
- Invoked by `feature-lifecycle` after MONITOR phase

### Workflow

```
1. Identify the completed feature:
   - If invoked with a feature name, use it
   - If invoked after finalize-branch, detect from the merged branch name
   - If ambiguous, ask the developer

2. Archive feature specs:
   - If .specs/features/<feature>/ exists:
     - Create .specs/features/_archive/ if it doesn't exist
     - Move .specs/features/<feature>/ → .specs/features/_archive/<feature>/
     - Log: "Archived specs for <feature>"
   - If no specs exist, skip

3. Clean stale plans:
   - Scan .cursor/plans/*.plan.md
   - For each plan where ALL to-dos are "completed" or "cancelled":
     - List the plan and ask: "This plan is fully executed. Archive it?"
     - If yes: move to .cursor/plans/_archive/
   - If no plans match, skip

4. Remove consumed handoff files:
   - If HANDOFF.md exists at project root and current session already loaded it:
     - Ask: "HANDOFF.md was consumed this session. Remove it?"
     - If yes: delete

5. Update ROADMAP.md (if exists):
   - If .specs/project/ROADMAP.md references the completed feature:
     - Mark it as [DONE] in the roadmap

6. Summary:
   - Report what was archived/cleaned
   - "Quick Sweep complete: archived 1 feature spec, 1 plan. Workspace is clean."
```

## Mode 2: Deep Clean

Thorough cleanup at sprint boundaries. Triggered manually or suggested during sprint retrospective.

### Trigger

- User says "deep clean", "housekeeping", "prune workspace"
- Suggested by `linear-project-management` during Sprint Retrospective workflow

### Workflow

```
1. Audit archived specs:
   - Scan .specs/features/_archive/
   - List features archived more than <pruneAfterDays> days ago (default: 90)
   - Ask: "These archived specs are older than 90 days. Delete permanently?"
   - If yes: delete the directories
   - If no: skip

2. Prune STATE-ARCHIVE.md:
   - If .specs/project/STATE-ARCHIVE.md exists:
     - Parse entries with dates
     - Identify entries older than <pruneAfterDays> days
     - Ask: "Found N decisions older than 90 days in STATE-ARCHIVE.md. Remove them?"
     - If yes: remove the entries, keeping recent ones intact

3. Prune .notebook/archive/:
   - If .notebook/archive/ exists:
     - List notes archived more than <pruneAfterDays> days ago
     - Ask: "Found N archived notes older than 90 days. Delete permanently?"
     - If yes: delete the files

4. Archived plans:
   - Scan .cursor/plans/_archive/
   - List plans archived more than <pruneAfterDays> days ago
   - Ask: "These archived plans are older than 90 days. Delete permanently?"
   - If yes: delete

5. Detect orphan files:
   - Look for common orphan patterns in project root:
     - *.bak, *.tmp, *.orig, *.swp
     - .DS_Store (outside .gitignore)
     - node_modules in unexpected locations
   - List any found and ask: "Found N potential orphan files. Review and delete?"

6. Detect stale branches:
   - Run: git branch -vv
   - Identify local branches where remote is gone (": gone]")
   - List them and ask: "These local branches have no remote. Delete them?"
   - If yes: git branch -d <branch> for each

7. Summary report:
   - Present what was cleaned:
     "Deep Clean complete:
      - Deleted 3 archived feature specs (>90 days)
      - Pruned 12 entries from STATE-ARCHIVE.md
      - Removed 5 archived notebook entries
      - Cleaned 2 orphan files
      - Deleted 4 stale local branches"
```

## What This Skill Does NOT Touch

- **Active `.notebook/` entries** — curation is handled by `code-navi` during every session
- **Active `STATE.md`** — size management is handled by `spec-driven`
- **Remote branches** — only local stale branches are cleaned
- **Source code files** — this skill never touches application code
- **Git history** — no rewriting, no force operations

## Integration

- **finalize-branch**: suggests Quick Sweep after merge (step 6)
- **feature-lifecycle**: invokes Quick Sweep after MONITOR phase
- **linear-project-management**: suggests Deep Clean during Sprint Retrospective
- **code-navi**: complements `.notebook/` curation (this skill handles archive pruning)
- **spec-driven**: complements `STATE.md` management (this skill handles STATE-ARCHIVE pruning)
