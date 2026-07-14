---
description: Conservative Pegasus IA global guidance for VS Code/Copilot
applyTo: "**"
---

# Pegasus IA global guidance

When a workspace contains Pegasus IA assets, use the workspace-local files as the source of truth before this global guidance:

1. `.github/copilot-instructions.md`
2. `.github/instructions/`
3. `.github/agents/pegasus-orchestrator.agent.md`
4. `AGENTS.md`
5. `docs/pegasus/`

Keep work local-first. Do not create app scaffolds, GitHub remotes, CI, deployment, database, or network resources unless the workspace docs explicitly require them.

Use English for operational instructions, internal communication, and generated agent-consumed artifacts. Only an explicit user instruction naming an artifact language overrides English; chat, persona, source language, and prior artifacts do not. User-facing conversation and localized public warnings may remain localized. Pegasus Memory descriptive prose is always English; preserve exact source data and record each source artifact's language.

This file is intentionally conservative and does not claim one-to-one behavior with OpenCode, Cursor, or any other agent runtime.
