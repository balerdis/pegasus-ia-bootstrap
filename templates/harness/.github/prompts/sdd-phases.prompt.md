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

Work only on the requested phase. Before moving forward, confirm the required prior docs exist and ask for user approval: proposal requires an approved PRD; spec requires approved PRD and proposal; design requires approved spec; tasks require approved design; apply requires an approved task slice; verify requires `docs/pegasus/apply-progress.md` and an implementation diff.

Before delegating or starting a phase/task, check `docs/pegasus/memory/tasks-log.md` and `docs/pegasus/apply-progress.md` for the same phase/task already in progress or completed. Avoid duplicate launches.

Use the direct-fix path for small, punctual, low-risk changes with clear acceptance criteria. Do not force the full SDD flow when a documented direct fix is safer and faster.

If applying, estimate review workload first. Stop and ask whether to split into chained PRs when implementation is likely to exceed about 400 changed lines or touch multiple unrelated areas. Implement only the next approved task slice and merge status into `docs/pegasus/apply-progress.md`.

For verification, use fresh context when possible: re-read PRD, proposal, spec, design, tasks, apply-progress, verify log, and changed files before judging completion. Record verification in `docs/pegasus/verify.md` and update `docs/pegasus/memory/` when facts, decisions, task state, handoff notes, or learnings change. Merge updates into existing useful history; do not overwrite prior progress, memory, apply-progress, or verification evidence.
