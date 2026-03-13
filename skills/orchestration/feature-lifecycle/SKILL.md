---
name: feature-lifecycle
description: Meta-skill that orchestrates the complete lifecycle of a feature — from Linear issue through specification, design, implementation, testing, review, merge, and deployment. Detects which phase a feature is in and invokes the appropriate skill. Resumes across sessions. Use when starting a new feature end-to-end, checking feature progress, or resuming work on an in-progress feature. Triggers on "start feature", "new feature", "feature lifecycle", "where are we on this feature", "resume feature", "what's next for this feature", "end-to-end", "full cycle". Do NOT use for individual phases (use the specific skill directly) or for project-level planning (use spec-driven).
metadata:
  author: T2E
  version: "1.0.0"
---

# Feature Lifecycle

Orchestrate the complete journey of a feature. One skill to rule them all.

## The Lifecycle

```
┌─────────┐   ┌─────────┐   ┌────────┐   ┌───────────┐   ┌─────────┐
│ SPECIFY │ → │ DESIGN  │ → │ TASKS  │ → │ IMPLEMENT │ → │  TEST   │
└─────────┘   └─────────┘   └────────┘   └───────────┘   └─────────┘
                                                               │
┌─────────┐   ┌─────────┐   ┌────────┐                        │
│ MONITOR │ ← │ DEPLOY  │ ← │ MERGE  │ ← ──── REVIEW ────────┘
└─────────┘   └─────────┘   └────────┘
```

Each phase maps to a skill:

| Phase | Skill | Key Action |
|-------|-------|------------|
| SPECIFY | spec-driven | Create spec.md with requirements |
| DESIGN | spec-driven | Create design.md with architecture |
| TASKS | spec-driven + linear-pm | Create tasks.md, sync to Linear |
| IMPLEMENT | code-navi | Build the feature |
| TEST | testing-strategy | Write and run tests |
| REVIEW | code-review | Pre-flight code review |
| MERGE | finalize-branch | PR, CI, merge |
| DEPLOY | deploy-release | Release to production |
| MONITOR | observability-setup | Verify in production |

## Phase Detection

When invoked, detect where the feature currently is:

```
1. Check Linear for the feature issue status (see _shared/references/linear-helpers.md)
2. Check .specs/features/<feature>/ for existing artifacts:
   - spec.md exists? → past SPECIFY
   - design.md exists? → past DESIGN
   - tasks.md exists? → past TASKS
3. Check git for implementation:
   - Feature branch exists with commits? → in IMPLEMENT
   - PR open? → in REVIEW/MERGE
4. Check deployment status:
   - Merged to main? → ready for DEPLOY
   - Deployed? → in MONITOR
```

Report current phase and what comes next.

## Starting a New Feature

```
1. Check Linear for the issue (or create one)
2. Move issue to "In Progress"
3. Invoke spec-driven → SPECIFY phase
   - Create .specs/features/<feature>/spec.md
4. Invoke spec-driven → DESIGN phase
   - Create .specs/features/<feature>/design.md
5. Invoke spec-driven → TASKS phase
   - Create .specs/features/<feature>/tasks.md
6. Invoke linear-pm → create sub-issues from tasks
7. For each task:
   a. Invoke code-navi → IMPLEMENT
   b. Invoke testing-strategy → TEST
   c. Update Linear issue status
8. Invoke code-review → REVIEW
9. Invoke finalize-branch → MERGE
10. Invoke deploy-release → DEPLOY
11. Invoke observability-setup → MONITOR (verify in production)
```

## Resuming a Feature

When resuming work across sessions:

```
1. Detect phase (see above)
2. Load context:
   - .specs/project/STATE.md (session state from spec-driven)
   - .notebook/ entries related to this feature (from code-navi)
   - Linear issue status and comments
3. Summarize current state to the developer
4. Continue from the detected phase
```

## Graceful Degradation

Not all skills may be installed. Handle missing skills:

- If a skill is unavailable, perform the phase manually with inline guidance
- Log which skills are missing: "Note: testing-strategy skill not available — running tests manually"
- Never block the lifecycle because a non-critical skill is missing
- Critical path (IMPLEMENT → MERGE) works without any optional skills

## Progress Dashboard

When asked "where are we?", show:

```
Feature: [name]
Linear: [issue-id] — [status]
Phase: [current phase] ■■■■■■□□□□ 60%

✓ SPECIFY  — spec.md created
✓ DESIGN   — design.md created
✓ TASKS    — 5 tasks, 3 done
→ IMPLEMENT — T4: working on auth middleware
○ TEST
○ REVIEW
○ MERGE
○ DEPLOY
○ MONITOR
```

## Post-Lifecycle: Cleanup

After MONITOR is complete and the feature is verified in production, invoke `workspace-hygiene` Quick Sweep:

```
12. Invoke workspace-hygiene → CLEANUP
    - Archive .specs/features/<feature>/
    - Clean completed plans referencing this feature
    - Update ROADMAP.md marking feature as done
```

If `workspace-hygiene` is not available, skip this step — it's optional but recommended to prevent artifact accumulation.

## Integration

This skill is the hub. It delegates to:
- **spec-driven**: SPECIFY, DESIGN, TASKS phases
- **linear-project-management**: issue tracking throughout
- **code-navi**: IMPLEMENT phase
- **testing-strategy**: TEST phase
- **code-review**: REVIEW phase
- **finalize-branch**: MERGE phase
- **deploy-release**: DEPLOY phase
- **observability-setup**: MONITOR phase
- **workspace-hygiene**: post-MONITOR cleanup (optional)
