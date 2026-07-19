---
description: Universal Pegasus workflow routing map
applyTo: "**"
---

# Pegasus workflow map

Use direct fix only for small, punctual, low-risk work with clear acceptance. Use SDD for broader, ambiguous, architectural, or higher-risk work.

Route `request -> PRD -> proposal -> spec -> design -> tasks -> apply -> verify -> handoff` through `.github/agents/pegasus-orchestrator.agent.md`. The coordinator loads `.github/references/orchestration/routing.md`; each specialist loads its exact `.github/references/phases/<phase>.md` and result contract.

Active artifacts live under `docs/pegasus/changes/<change-id>/`. Root phase files are templates. Missing or contradictory evidence, approval, exact references, delegation, or capability blocks; do not absorb a specialist workflow into this eager rule.
