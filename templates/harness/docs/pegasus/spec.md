# Specification: {{PROJECT_NAME}}

## Purpose

Define acceptance-level requirements and scenarios for approved SDD work.

Use this file as the acceptance contract for Copilot-guided work. Prompts and agents under `.github/` should reference these requirements rather than inventing behavior.

## Source Status

| Source | Path | Owner/Date | Status | Notes |
|--------|------|------------|--------|-------|
| PRD | `docs/pegasus/prd.md` | TBD | Approved / Pending / Blocked | TBD |
| Proposal | `docs/pegasus/proposal.md` | TBD | Approved / Pending / Blocked | TBD |

Spec work requires an approved PRD and approved proposal. If either is not approved, stop before adding requirements.

## Requirements

### Requirement: TBD

The system MUST ...

#### Scenario: TBD

- GIVEN ...
- WHEN ...
- THEN ...

### Requirement: Example requirement

The system MUST reject duplicate apply work for the same approved task slice.

#### Scenario: Duplicate apply slice is already complete

- GIVEN `docs/pegasus/apply-progress.md` shows task `1.2` is complete
- WHEN apply is asked to start task `1.2` again
- THEN apply stops before editing implementation files
- AND it records or reports that verification or the next approved slice should happen instead

## Acceptance Edge Cases

| Edge case | Expected behavior | Related requirement |
|-----------|-------------------|---------------------|
| TBD | TBD | TBD |

## Non-Goals / Out of Scope

- Technical architecture decisions belong in `docs/pegasus/design.md`.
- Implementation task breakdown belongs in `docs/pegasus/tasks.md`.
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

## Open Questions

- TBD
