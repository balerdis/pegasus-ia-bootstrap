---
name: pegasus-memory-update
description: Record Pegasus operational memory through MCP
tools:
  - read
  - search
---

# Memory update prompt

Follow `.github/instructions/pegasus-memory.instructions.md`: all durable descriptive prose is English, exact source data is preserved, and every persisted artifact reference records `Artifact language: <language>`.

Review recent changes and call the `pegasus-memory-mcp` `health` tool before the first recovery or save attempt. If `health` succeeds, recover context and ensure write preconditions: when recovery returns `not_found` with `project_not_found`, call `ensure_project`; when recording a new change/PRD under `docs/pegasus/changes/<change-id>/`, call `ensure_change` before `record_artifact` or change-scoped observations. Then record durable operational memory through MCP:

- Active project/change context.
- Decisions and tradeoffs.
- Bugfixes, root causes, and remediation notes.
- Discoveries, gotchas, conventions, and reusable patterns.
- Configuration/environment changes and user constraints/preferences.
- Task progress, status, and blockers.
- Artifact paths, status, and summaries.
- Verification commands, evidence, deviations, verdicts, and remediation needs.
- Handoffs and recovery state.
- Observations, gotchas, and reusable discoveries.

Keep records concise and factual. Before ending or pausing, save a concise handoff/session summary after MCP `health` succeeds. Merge updates into existing useful history instead of replacing prior progress, evidence, blockers, or decisions. Use MCP tool inputs, outputs, and documented capabilities as the contract; do not depend on server internals. Preserve MCP consumer states: `not_found`, `ambiguous`, `read_error`, and `persistence_error` are not MCP unavailability. Treat `persistence_error` or foreign-key write failures as precondition/flow bugs to report clearly, not as unavailable MCP.

If `pegasus-memory-mcp` is unavailable or `health` cannot be called successfully, show exactly: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`. Continue artifact work only if appropriate, but do not claim persistent memory was saved.

Do not write retrospective Markdown memory. `docs/pegasus/memory/` is deprecated and is not an active backend, fallback, or co-source for operational memory.
