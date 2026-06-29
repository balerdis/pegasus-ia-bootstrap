---
name: pegasus-sdd-phases
description: Work through Pegasus IA SDD phases
tools:
  - read
  - search
  - edit
  - agent
---

# SDD phases prompt

Use `docs/pegasus/` as the source of truth: request → PRD → proposal → spec → design → tasks → apply → verify → handoff.

Work only on the requested phase. Before moving forward, confirm the required prior docs exist and ask for user approval:

| Phase | Required docs/context | Output |
|-------|-----------------------|--------|
| PRD | User request and current memory | `docs/pegasus/prd.md` with approval status |
| Proposal | Approved `docs/pegasus/prd.md` | `docs/pegasus/proposal.md` |
| Spec | Approved PRD and approved proposal | `docs/pegasus/spec.md` requirements and scenarios |
| Design | Approved proposal and approved spec | `docs/pegasus/design.md` technical approach |
| Tasks | Approved spec and approved design | `docs/pegasus/tasks.md` reviewable slices |
| Apply | Approved spec, design, tasks, and apply-progress | Implementation for only the next approved slice plus `docs/pegasus/apply-progress.md` updates |
| Verify | Tasks, apply-progress, verify log, implementation diff, and PRD/proposal/spec/design when possible | `docs/pegasus/verify.md` evidence and verdict |

Before delegating or starting a phase/task, check `docs/pegasus/memory/tasks-log.md` and `docs/pegasus/apply-progress.md` for the same phase/task already in progress or completed. Avoid duplicate launches.

Use the direct-fix path for small, punctual, low-risk changes with clear acceptance criteria. Do not force the full SDD flow when a documented direct fix is safer and faster.

Spec requires an approved PRD and approved proposal. It writes acceptance behavior only: requirements, edge cases, non-goals, traceability, and `GIVEN` / `WHEN` / `THEN` scenarios. Do not design architecture, write implementation tasks, or edit code from spec.

Design writes the technical approach only: decisions, tradeoffs, alternatives, affected areas/files, data/control flow, testing strategy, rollout/rollback, risks, and open questions. Do not implement code or create the task checklist from design.

Tasks writes the implementation plan only: review workload forecast, exact guard lines, dependency/order, verification, risk, and rollback per slice. Include `Decision needed before apply: Yes|No`, `Chained PRs recommended: Yes|No`, and `400-line budget risk: Low|Medium|High`. Do not implement code from tasks.

If applying, estimate review workload first and honor the tasks guard lines. Stop and ask whether to split into chained PRs when implementation is likely to exceed about 400 changed lines or touch multiple unrelated areas. Implement only the next approved task slice, check tasks-log/apply-progress for duplicate work, and merge status into `docs/pegasus/apply-progress.md`. Apply may record preliminary notes/evidence, but it does not replace the verify phase.

For verification, use fresh context when possible: re-read PRD, proposal, spec, design, tasks, apply-progress, verify log, and changed files before judging completion. Verify the implementation against all of those sources, not just tests. Record a compliance matrix, commands/results, changed files reviewed, deviations, risks, runtime/manual evidence, and final verdict in `docs/pegasus/verify.md`. Do not make unrelated implementation changes during verify unless the user separately asks for remediation. Update `docs/pegasus/memory/` when facts, decisions, task state, handoff notes, or learnings change. Merge updates into existing useful history; do not overwrite prior progress, memory, apply-progress, or verification evidence.
