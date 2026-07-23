# Tasks: Durable Agent Communication

## Review Workload Forecast

| Field | Value |
|---|---|
| Estimated changed lines | ~2,500; corrective slices 180–350 |
| Suggested split | PRD PR → R6 → routing PR → R7 → phases |
| Delivery strategy / chain | ask-always / stacked-to-main; no size exception |

Decision needed before apply: No
Chained PRs recommended: Yes
Chain strategy: stacked-to-main
400-line budget risk: High

R5 is preserved: integrated PRD found six gaps but edited/persisted and emitted success/approval. Invalidated; Phase 2–10 wait for R7.

### Suggested Work Units

| Unit | Goal | PR | Test/harness | Rollback |
|---|---|---|---|---|
| 0 | Planning complete | merged | review/N/A | planning files |
| 1 | Doc-designer correction | PR 1 → `main` | PRD/bootstrap | doc-designer/PRD/tests |
| R6 | Specialist gate | no PR | direct isolate | workspace/logs/DB |
| 2 | Routing return | PR 2 → `main` | routing/bootstrap | orchestrator/routing/tests |
| R7 | Interaction gate | no PR | isolated flow | workspace/logs/DB |
| 3–11 | Remaining | stacked | phase/bootstrap | phase slice |

Units record command/digests/Memory outcome in `apply-progress.md`. R6/R7 preserve revision, workspace, payload, logs, isolated DB/export. Never erase history.

## Slice 0: Planning Baseline
- [x] 0.1 Approved planning baseline merged; no runtime PRD work belonged to this slice.

## Phase 1: PRD Corrective Migration
- [x] 1.1 Link R5 invalidation/supersession/rework in `apply-progress.md`; retain history.
- [x] 1.2 RED: gaps → questions/`blocked`; no edit/ensure/project/Memory/advance. Scope `templates/harness/.github/agents/doc-designer.agent.md`, `references/phases/prd.md`, specialist refs/tests.
- [x] 1.3 GREEN doc-designer vertical migration: compact input, lazy refs, owned behavior/persistence/response, fail-closed gate; no routing change.
- [ ] 1.4 Bootstrap, focused contract, evidence, PR 1 merge (≤800 lines).

## Operational Gate R6 (after PR 1 merges)
- [ ] R6.1 Isolated generated workspace; direct doc-designer invocation with exact compact payload; preserve required evidence.
- [ ] R6.2 Accept gaps → grouped questions/blocked/no edit/ensure/project/Memory/approval. Model evidence only; failure blocks Unit 2.

## Routing-Return Corrective Slice (after R6 passes)
- [ ] 1.5 RED invalid-result reconciliation; scope `templates/harness/.github/agents/pegasus-orchestrator.agent.md`, `references/orchestration/routing.md`, routing tests.
- [ ] 1.6 GREEN boundary validation only; bootstrap, routing contract, evidence, PR 2 merge (≤800 lines).

## Operational Gate R7 (after PR 2 merges)
- [ ] R7.1 Isolated orchestrator → doc-designer → orchestrator gap/resolved paths; preserve required evidence.
- [ ] R7.2 Accept gaps blocked/no edit/no persistence/no approval; resolved requires durable evidence/valid advance. Link R5/R6/R7; pass releases Phase 2.

## Phases 2–10: Pending After R7
- [ ] 2.1 Proposal: RED, Atomic migration, delete `results/proposal-result-v1.md`.
- [ ] 3.1 Spec: RED, Atomic migration, delete `results/spec-result-v1.md`.
- [ ] 4.1 Design: RED, Atomic migration, delete `results/design-result-v1.md`.
- [ ] 5.1 Tasks: RED reconciliation, Atomic migration, delete legacy task contracts.
- [ ] 6.1 Apply: RED progress/recovery, Atomic migration, delete legacy apply contract.
- [ ] 7.1 Verify: RED readiness/remediation, Atomic migration, delete legacy verify contract.
- [ ] 8.1 Handoff: RED closure/recovery, Atomic migration, delete legacy handoff contract.
- [ ] 9.1 Memory: RED observation/recovery, Atomic migration, delete legacy Memory contract.
- [ ] 10.1 After R7/phases 2–9, delete residual routing/contracts; prove source/bootstrap/wheel equivalence.
