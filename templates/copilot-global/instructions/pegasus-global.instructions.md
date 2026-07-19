---
description: Conservative Pegasus IA global fallback for VS Code/Copilot
applyTo: "**"
---

# Pegasus global fallback

This is fallback guidance, never phase authorization. When present, workspace-local assets override it in this order: `.github/copilot-instructions.md`, `.github/agents/pegasus-orchestrator.agent.md`, `.github/instructions/`, `AGENTS.md`, then the exact manual references selected by those assets.

Do not execute a Pegasus phase, edit artifacts, or persist workflow state from this global file. If the local coordinator or its exact required references are absent, stop and ask for the workspace workflow instead of reconstructing a contract.

Until local authority is loaded, keep work local and reversible; do not create product scaffolding, infrastructure, remotes, CI, deployment, databases, or network resources. Agent-consumed artifacts default to English unless the user explicitly names another artifact language.
