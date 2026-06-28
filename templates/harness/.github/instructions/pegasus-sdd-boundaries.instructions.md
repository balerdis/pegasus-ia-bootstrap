---
description: SDD boundaries for Pegasus IA work
applyTo: "**"
---

# SDD boundaries

Treat proposal, spec, design, and tasks as gates:

- Do not implement behavior that is outside `docs/pegasus/tasks.md`.
- Do not bypass `docs/pegasus/spec.md`; acceptance scenarios are the contract.
- Do not change architecture without updating `docs/pegasus/design.md` and `docs/pegasus/memory/decisions.md`.
- Do not mark work complete until `docs/pegasus/verify.md` contains the commands and outcomes used to validate it.

If a change exceeds the current task scope, split it into a new documented work unit before editing.
