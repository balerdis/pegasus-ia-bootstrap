---
description: Pegasus IA workflow and documentation order
applyTo: "**"
---

# Pegasus IA workflow

Use the smallest safe workflow. Small, punctual, low-risk changes with clear acceptance criteria may use a direct-fix path with memory and verification updates. Broader, ambiguous, architectural, or higher-risk changes use the local SDD flow under `docs/pegasus/`: request, PRD, proposal, spec, design, tasks, apply, verify, and handoff.

If requirements are missing, contradictory, or too broad, stop and clarify or update the docs before editing implementation files.

Prefer small, reviewable work units. Each unit should include its verification evidence and a clear rollback boundary.

Before moving to the next SDD phase, confirm the required prior docs exist and ask for user approval. Proposal requires an approved PRD.

Before delegating or starting a phase/task, check `docs/pegasus/memory/tasks-log.md` and `docs/pegasus/apply-progress.md` for matching work already in progress or completed. Do not launch duplicate work for the same phase/task.

Before implementation, estimate review workload. If the change is likely to exceed about 400 changed lines or touch multiple unrelated areas, stop and ask whether to split into chained PRs.

During apply, merge implementation slices, changed files, evidence, blockers, and next action into `docs/pegasus/apply-progress.md`.

During verify, use fresh context when possible by re-reading PRD, proposal, spec, design, tasks, apply-progress, verify log, and changed files before judging completion. This is an operational rule, not a runtime guarantee.
