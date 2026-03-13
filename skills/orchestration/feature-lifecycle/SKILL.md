---
name: feature-lifecycle
description: Meta-skill that orchestrates the complete lifecycle of a feature — from Linear issue through specification, design, implementation, testing, review, merge, and deployment. Detects which phase a feature is in and invokes the appropriate skill. Resumes across sessions. Use when starting a new feature end-to-end, checking feature progress, or resuming work on an in-progress feature. Triggers on "start feature", "new feature", "feature lifecycle", "where are we on this feature", "resume feature", "what's next for this feature", "end-to-end", "full cycle". Do NOT use for individual phases (use the specific skill directly) or for project-level planning (use spec-driven).
metadata:
  author: T2E
  version: "1.1.0"
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
| REVIEW | code-review + security-best-practices | Pre-flight code review + security scan |
| DOCUMENT | docs-writer (optional) | Update docs if feature is user-facing |
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
   - If feature touches auth, sensitive data, or public APIs:
     invoke security-best-practices for a targeted security scan
9. Invoke docs-writer → DOCUMENT (optional)
   - If feature is user-facing or changes API contracts:
     update relevant docs (README, API docs, guides)
   - If no docs impact, skip this step
10. Invoke finalize-branch → MERGE
11. Invoke deploy-release → DEPLOY
    - Auto-deploy (Vercel/Netlify/merge-triggered): verify the
      automatic deployment succeeded via deployment URL or checks
    - Manual deploy: invoke deploy-release explicitly with
      pre-deploy checklist, versioning, and release notes
12. Invoke observability-setup → MONITOR (verify in production)
```

## Resuming a Feature

When resuming work across sessions:

```
1. Detect phase (see above)
2. Load context from all three persistence systems:
   a. .specs/HANDOFF.md (if exists) — session-specific handoff with
      completed/in-progress/pending items and blockers. Consume it
      (it's a one-time snapshot from the last session pause).
   b. .specs/project/STATE.md — persistent project state: decisions,
      blockers, lessons learned across all sessions.
   c. .notebook/INDEX.md — accumulated codebase intelligence: flows,
      gotchas, corrections, patterns (from code-navi).
   d. Linear issue status and comments — current tracking state.
3. Summarize current state to the developer, noting:
   - What was in progress when paused (from HANDOFF.md)
   - Any active blockers (from STATE.md)
   - Relevant technical context (from .notebook/)
4. Continue from the detected phase
```

**Persistence system roles** (don't confuse them):
- `.specs/HANDOFF.md` = ephemeral session snapshot (consumed on resume, then removed)
- `.specs/project/STATE.md` = long-lived project memory (decisions, blockers, preferences)
- `.notebook/` = codebase intelligence (technical discoveries, patterns, gotchas)

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
○ REVIEW     (+ security scan if sensitive)
○ DOCUMENT   (if user-facing)
○ MERGE
○ DEPLOY
○ MONITOR
```

## Post-Lifecycle: Cleanup

After MONITOR is complete and the feature is verified in production, invoke `workspace-hygiene` Quick Sweep:

```
13. Invoke workspace-hygiene → CLEANUP
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
- **code-review**: REVIEW phase (pre-flight)
- **security-best-practices**: REVIEW phase (security scan for sensitive features)
- **docs-writer**: DOCUMENT phase (optional, for user-facing features)
- **finalize-branch**: MERGE phase
- **deploy-release**: DEPLOY phase
- **observability-setup**: MONITOR phase
- **workspace-hygiene**: post-MONITOR cleanup (optional)
