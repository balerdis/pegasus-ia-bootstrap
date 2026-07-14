---
description: Start or resume a Pegasus IA workspace safely
---

# Start Pegasus IA work

Use English for operational instructions, internal communication, and generated artifacts unless the user explicitly names another language for a specific artifact. Do not infer an override from chat, persona, source, or prior artifact language; user-facing conversation may remain localized.

Read the workspace-local Pegasus assets before editing:

- `.github/copilot-instructions.md`
- `.github/instructions/`
- `.github/agents/pegasus-orchestrator.agent.md`
- `AGENTS.md`
- Current PRD, proposal, spec, design, tasks, apply-progress, and verify files under `docs/pegasus/` or `docs/pegasus/changes/<change-id>/`

Recover operational memory through `pegasus-memory-mcp` when available. Persist descriptive prose in English, preserve exact source data, and record `Artifact language: <language>` for artifact references. If MCP memory is unavailable, show exactly: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`. Do not fall back to `docs/pegasus/memory/` as an active memory backend.

Summarize the current task slice, the acceptance criteria, and the verification command you will run. If the workspace does not contain Pegasus IA assets, stop and ask for the intended workflow.
