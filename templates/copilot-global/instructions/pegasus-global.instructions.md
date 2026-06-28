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

This file is intentionally conservative and does not claim one-to-one behavior with OpenCode, Cursor, or any other agent runtime.
