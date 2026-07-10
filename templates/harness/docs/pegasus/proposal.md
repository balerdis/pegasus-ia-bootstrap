# Proposal: {{PROJECT_NAME}}

Created: `{{DATE}}`  
Target: `{{TARGET_PATH}}`

Use this template inside `docs/pegasus/changes/<change-id>/proposal.md` for change-specific SDD work. The proposal file is the source of truth for scope and approach; MCP memory may store summaries, status, artifact references, and recovery notes only.

## Intent

Describe the outcome this project should achieve.

This proposal bridges the approved PRD and the future spec. It is not a technical design, requirements matrix, task plan, or implementation record.

## PRD Source / Status

Proposal work requires an approved `docs/pegasus/changes/<change-id>/prd.md`. If the PRD is missing, unresolved, or not explicitly approved, stop and complete it first.

| PRD Source | Approval Owner | Approval Date | Status |
|------------|----------------|---------------|--------|
| `docs/pegasus/changes/<change-id>/prd.md` | TBD | TBD | Draft |

## Project Context Consulted

- [ ] MCP active project/change context reviewed when available
- [ ] MCP decisions and observations reviewed when available
- [ ] MCP task progress and blockers reviewed when available
- [ ] MCP handoff and recovery notes reviewed when available
- [ ] File artifacts under `docs/pegasus/changes/<change-id>/` reviewed

If MCP memory is unavailable, continue from file artifacts and do not claim persistent memory was recovered or saved.

## Scope

### In Scope

- TBD

### Out of Scope

- TBD

## Users

Describe who will use the result and what problem it solves.

## Context / Situations

Summarize the target situations or workflows from the approved PRD.

## Lightweight Approach

Summarize the product/workflow direction at a high level. Do not include architecture, data models, implementation steps, or task breakdowns.

Use `.github/agents/pegasus-orchestrator.agent.md` as the primary VS Code/Copilot entry point for guided work. Keep `AGENTS.md` and `docs/pegasus/` as portable sources of truth.

## Assumptions / Decision Gaps

| Assumption or Gap | Impact | Owner / Next Step |
|-------------------|--------|-------------------|
| TBD | TBD | TBD |

Record only assumptions explicitly stated in the approved PRD. Record every material detail absent from the PRD as an unresolved gap with its impact; do not invent a default or state that the PRD preserved it.

## PRD Traceability

| Proposal Claim | Explicit PRD Text / Section | Status |
|----------------|-----------------------------|--------|
| TBD | TBD | Traceable or unresolved gap |

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| TBD | TBD | TBD |

## Rollback Plan

Explain how to safely undo the change.

## Acceptance Criteria

- [ ] TBD
- [ ] PRD is approved and linked to this proposal.
- [ ] Copilot prompts, instructions, and agent handoffs stay aligned with this proposal.

## Handoff to Spec

List the product decisions, scope boundaries, risks, and open questions the spec writer should turn into requirements and acceptance scenarios.

- TBD

## Explicit Exclusions

- No requirements matrix.
- No technical design, architecture, data models, or implementation tasks.
- No PR splitting or review-budget decisions.
- No application code changes.
