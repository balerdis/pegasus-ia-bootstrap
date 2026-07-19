# Pegasus IA workspace instructions

This workspace uses Pegasus IA as a local documentation and workflow harness. It does not authorize product code, infrastructure, remotes, CI, deployment, databases, or network services by itself.

## Entry and authority

Start with `.github/agents/pegasus-orchestrator.agent.md`; `AGENTS.md` is the portable map. Active artifacts live under `docs/pegasus/changes/<change-id>/`. Root `docs/pegasus/*.md` files are canonical templates; root `prd.md` is also the pre-change entry template.

Precedence is current macro > phase reference > shared reference > workspace default > global fallback. Lower authority cannot weaken a higher safety gate. A same-level conflict or missing required local owner blocks work before edits.

The coordinator routes only. Phase agents own phase execution, validation, persistence, and results. Load only the references named by the selected agent or prompt; `.github/references/**` is manual-only context.

- Authority and conflicts: `.github/references/shared/authority.md`
- Common specialist rules: `.github/references/shared/phase-common.md`
- Delegation ownership: `.github/references/shared/delegation-ownership.md`
- Pegasus Memory: `.github/references/shared/persistence.md`
- Status/readiness: `.github/references/shared/status-readiness.md`
- Skills: `.github/references/shared/skill-resolution.md`
- Result envelopes: `.github/references/shared/result-envelope.md`
- Routing: `.github/references/orchestration/routing.md`
- Phase contracts: `.github/references/phases/<phase>.md`
- Result contracts: `.github/references/results/<phase>-result-v<version>.md`
- Tasks transport: `.github/references/results/tasks-transport-v2.md`

Generated agent-consumed artifacts default to English unless the user explicitly names another language for that artifact. Never infer artifact language from chat, persona, source language, or prior artifacts.

Use current-change evidence and small reversible work units. Do not invent missing requirements, approvals, capabilities, persistence, or verification. If the selected agent, exact required reference, authorization, or execution capability is unavailable, return a truthful blocked result instead of copying or reconstructing its contract.
