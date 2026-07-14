# Proposal: {{PROJECT_NAME}}

Created: `{{DATE}}`  
Target: `{{TARGET_PATH}}`

Artifact language defaults to English regardless of chat language, persona, source language, or prior artifacts. Use another language only when the user explicitly names it for this artifact; then translate all human-readable headings, labels, and scaffolding consistently and run the existing language gate.

Validation mapping for an explicit Spanish override only: `Created:` becomes `Creado:` and `Target:` becomes `Destino:`. These Spanish labels are not default template content.

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

## Related Change Traceability

Do not search, read, or reuse neighboring or unrelated change artifacts by default. The current change PRD is the only product-content source; this canonical managed template and the current change placeholder are the only structure/format source. Consult another change only when the current PRD, active MCP context, or direct user instruction explicitly declares a dependency/relation.

| Reference / Change Consulted | Exact Purpose / Dependency | Not an Implicit Scope Source |
|------------------------------|----------------------------|------------------------------|
| None by default | N/A | Yes |

When a related change is consulted, replace the default row and state explicitly that its scope, decisions, assumptions, wording, and style were not inherited implicitly.

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

## Assumptions

| Assumption | Explicit PRD Source | Status |
|------------|---------------------|--------|
| TBD | TBD | Traceable |

Record only assumptions explicitly stated in the approved PRD. Do not turn an unstated detail into a preserved PRD assumption.

## Open Decisions / Material Gaps

Reconcile every material gap before proposal finalization. A material gap is a missing, contradictory, or unverified detail that can change scope, user-visible behavior, acceptance, risk, or a phase gate. Each row has exactly one terminal disposition: resolved only by explicit reliable current-change evidence or a direct user answer, or unresolved with all required fields below. An ambiguous MCP response never resolves a material gap.

| Material Gap | Status | Resolution Evidence / Source | Owner | Impact | Next Step | Needed-by Gate |
|--------------|--------|------------------------------|-------|--------|-----------|----------------|
| _No material gaps identified; remove this row before recording a gap._ | No gaps identified | Verified against the approved PRD | N/A | N/A | N/A | Proposal finalization |

Classify gaps before writing. For a blocking gap, ask one concise question and stop before writing or finalizing the proposal; after an explicit reliable answer resolves it, record the resolved evidence in this section before proceeding. Record non-blocking unresolved gaps visibly in this section; do not invent a default. Reconcile this section again before marker validation and MCP persistence. The final response must summarize resolved and unresolved material gaps and must not claim no open questions when unresolved entries remain.

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
