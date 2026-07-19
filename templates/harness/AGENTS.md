# {{PROJECT_NAME}} Agent Guide

Target path: `{{TARGET_PATH}}`  
Harness created: `{{DATE}}`

This portable map points to Pegasus IA workspace owners; it does not duplicate phase contracts.

## Entry points

- Coordinator: `.github/agents/pegasus-orchestrator.agent.md`
- Defaults and boundaries: `.github/copilot-instructions.md`, `.github/instructions/`
- Commands and manual contracts: `.github/prompts/`, `.github/references/`
- Active artifacts: `docs/pegasus/changes/<change-id>/`
- Legacy compatibility only: `.cursor/rules/`

Root `docs/pegasus/*.md` files are canonical templates. Root `prd.md` may start discovery before an active change is selected. Pegasus Memory is the operational persistence interface; Markdown memory is not a fallback.

Precedence is current macro > phase reference > shared reference > workspace default > global fallback. Same-level conflicts and missing exact local references block before edits.

| Concern | Canonical owner |
| --- | --- |
| Authority/conflicts | `.github/references/shared/authority.md` |
| Routing/authorization | `.github/references/orchestration/routing.md` |
| Specialist/common rules | `.github/references/shared/delegation-ownership.md`, `shared/phase-common.md` |
| Phase execution | `.github/references/phases/<phase>.md` |
| Persistence | `.github/references/shared/persistence.md` |
| Status/skills/results | `.github/references/shared/status-readiness.md`, `shared/skill-resolution.md`, `shared/result-envelope.md` |
| Phase result schema | `.github/references/results/<phase>-result-v<version>.md` |
| Tasks wire transport | `.github/references/results/tasks-transport-v2.md` |

The coordinator routes; the matching specialist owns edits, checks, persistence, and its result. Load only references required by the selected agent or prompt. Never add `applyTo` to `.github/references/**`.

- Agent-consumed artifacts default to English unless the user explicitly names another language for that artifact.
- Use current-change evidence; do not infer requirements, approvals, completed work, or successful persistence.
- Do not create product code, infrastructure, remotes, CI, deployment, databases, or network services unless active approved artifacts authorize them.
- Prefer reversible changes. Missing agent, reference, authorization, or capability means blocked, not an improvised fallback.
