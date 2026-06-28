# Pegasus IA workspace instructions

This workspace uses the Pegasus IA VS Code/Copilot harness. The harness provides local workflow, documentation, and Markdown memory only. It does not authorize framework scaffolding, GitHub setup, CI, deployment, database setup, or business/domain application code by itself.

## Primary entry point

Use `.github/agents/pegasus-orchestrator.agent.md` as the primary Copilot agent for project work. The orchestrator coordinates SDD phase agents and selected specialist agents through Copilot custom-agent handoffs where supported.

## Source of truth

Before changing files, read `docs/pegasus/memory/context.md`, `decisions.md`, `tasks-log.md`, then `docs/pegasus/proposal.md`, `spec.md`, `design.md`, and `tasks.md`.

Record verification in `docs/pegasus/verify.md` and update `docs/pegasus/memory/` whenever facts, decisions, task status, handoff state, or learnings change.

## Operating boundaries

- Keep work local-first and reversible.
- Do not create app code, remotes, CI, deployment, database, framework scaffolding, MCP services, or network dependencies unless the local SDD docs explicitly request them.
- Preserve user files unless overwrite behavior is explicitly approved.

Cursor files under `.cursor/rules/` are legacy compatibility guidance. Prefer the Copilot assets in `.github/` for VS Code/Copilot sessions.
