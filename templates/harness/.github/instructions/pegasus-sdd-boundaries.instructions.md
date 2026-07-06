---
description: SDD boundaries for Pegasus IA work
applyTo: "**"
---

# SDD boundaries

Treat proposal, spec, design, and tasks as gates:

- Do not implement behavior that is outside `docs/pegasus/tasks.md`.
- Do not bypass `docs/pegasus/spec.md`; acceptance scenarios are the contract.
- Keep PRD, proposal, spec, design, tasks, apply-progress, and verify as file artifacts under `docs/pegasus/` or `docs/pegasus/changes/<change-id>/`.
- Do not change architecture without updating `docs/pegasus/design.md` and recording the durable decision through MCP when available.
- Do not duplicate phase/task work already marked in progress or completed in MCP task progress or `docs/pegasus/apply-progress.md`.
- Do not skip `docs/pegasus/apply-progress.md` when implementing; merge implementation status, changed files, evidence, blockers, and next action there.
- Do not mark work complete until `docs/pegasus/verify.md` contains the commands and outcomes used to validate it.
- Do not use `docs/pegasus/memory/` as an operational memory backend, fallback, or co-source. It is deprecated after MCP integration.

If a change exceeds the current task scope, split it into a new documented work unit before editing.
