<!-- pegasus-harness:start path=docs/pegasus/changes/<change-id>/spec.md ownership=full-file -->
# Specification: {{PROJECT_NAME}}

Use this template inside `docs/pegasus/changes/<change-id>/spec.md` for change-specific SDD work. The spec file is the acceptance source of truth; Pegasus Memory (`pegasus-memory-mcp`) may summarize requirements, status, and artifact paths only. Preserve the managed markers exactly and edit only between them.

## Purpose

Define acceptance-level requirements and scenarios for approved SDD work.

Use this file as the acceptance contract for Copilot-guided work. Prompts and agents under `.github/` should reference these requirements rather than inventing behavior.

## Source Status

| Source | Path | Owner/Date | Status | Notes |
|--------|------|------------|--------|-------|
| PRD | `docs/pegasus/changes/<change-id>/prd.md` | TBD | Approved / Pending / Blocked | TBD |
| Proposal | `docs/pegasus/changes/<change-id>/proposal.md` | TBD | Approved / Pending / Blocked | TBD |

Spec work requires an approved in-file PRD and approved in-file proposal. Conversational approval cannot override Draft, Pending, unchecked, or inconsistent artifacts. When approval table, status, or checkbox indicators exist, they must agree before adding requirements.

## Source Isolation

The current change PRD and proposal are the only default product and requirements sources. Do not inspect or reuse neighboring or unrelated changes for requirements, scenarios, wording, style, or formatting. Use this canonical managed template/current placeholder only for structure. Consult another change only when the current PRD, active Pegasus Memory context, or direct user instruction explicitly declares a dependency/relation; disclose the reference, purpose, and that it was not an implicit scope source.

## Requirements

### Requirement: TBD

The system MUST ...

#### Scenario: TBD

- GIVEN ...
- WHEN ...
- THEN ...

Replace each placeholder with behavior explicitly supported by the approved current-change PRD and proposal. Do not retain or add example behavior that is not traceable to those sources.

## Acceptance Edge Cases

| Edge case | Expected behavior | Related requirement |
|-----------|-------------------|---------------------|
| TBD | TBD | TBD |

## Related Change Traceability

| Reference / Change Consulted | Exact Purpose / Dependency | Not an Implicit Scope Source |
|------------------------------|----------------------------|------------------------------|
| None by default | N/A | Yes |

## Non-Goals / Out of Scope

- Technical architecture decisions belong in `docs/pegasus/changes/<change-id>/design.md`.
- Implementation task breakdown belongs in `docs/pegasus/changes/<change-id>/tasks.md`.
- Code changes are out of scope for spec work.
- TBD project-specific non-goal.

## Non-Functional Requirements

- Performance: TBD
- Accessibility: TBD
- Security: TBD
- Observability: TBD

## Traceability

| Requirement | PRD reference | Proposal reference | Scenario(s) | Status |
|-------------|---------------|--------------------|-------------|--------|
| TBD | TBD | TBD | TBD | Draft |

Every normative requirement MUST link to explicit approved PRD/proposal evidence or a visible unresolved material gap.

## Open Questions / Material Gaps

Reconcile every material requirements or acceptance gap before persistence and final response. Resolve it only with reliable current-change evidence or a direct user answer, or retain it visibly with owner, impact, next step, and needed-by gate. An ambiguous Pegasus Memory response never resolves a gap. A blocking gap requires one concise question and a stop before finalizing.

| Material Gap | Status | Resolution Evidence / Source | Owner | Impact | Next Step | Needed-by Gate |
|--------------|--------|------------------------------|-------|--------|-----------|----------------|
| _No material gaps identified; remove this row before recording a gap._ | No gaps identified | Verified against approved sources | N/A | N/A | N/A | Spec finalization |

<!-- pegasus-harness:end path=docs/pegasus/changes/<change-id>/spec.md -->
