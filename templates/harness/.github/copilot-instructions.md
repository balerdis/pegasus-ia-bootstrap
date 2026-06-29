# Pegasus IA workspace instructions

This workspace uses the Pegasus IA VS Code/Copilot harness. The harness provides local workflow, documentation, and Markdown memory only. It does not authorize framework scaffolding, GitHub setup, CI, deployment, database setup, or business/domain application code by itself.

## Primary entry point

Use `.github/agents/pegasus-orchestrator.agent.md` as the primary Copilot agent for project work. The orchestrator coordinates SDD phase agents and selected specialist agents through Copilot custom-agent handoffs where supported.

## Source of truth

Before changing files, read `docs/pegasus/memory/context.md`, `decisions.md`, `tasks-log.md`, then `docs/pegasus/prd.md`, `proposal.md`, `spec.md`, `design.md`, and `tasks.md`.

Record verification in `docs/pegasus/verify.md` and update `docs/pegasus/memory/` whenever facts, decisions, task status, handoff state, or learnings change. Merge updates into existing useful history; do not overwrite prior progress, memory, or verification evidence.

Record the project-selected Copilot model preference in `docs/pegasus/memory/context.md` or workspace settings when available. Use one model for all phases in this first release; do not promise per-phase model routing or hard runtime control from Pegasus docs alone.

## Operating boundaries

- Keep work local-first and reversible.
- Do not create app code, remotes, CI, deployment, database, framework scaffolding, MCP services, or network dependencies unless the local SDD docs explicitly request them.
- Preserve user files unless overwrite behavior is explicitly approved.
- Use the direct-fix path for small, punctual, low-risk changes; use SDD for broader, ambiguous, architectural, or higher-risk changes.
- Before large implementation, stop and ask whether to split into chained PRs if the estimate exceeds about 400 changed lines or touches multiple unrelated areas.

Cursor files under `.cursor/rules/` are legacy compatibility guidance. Prefer the Copilot assets in `.github/` for VS Code/Copilot sessions.
