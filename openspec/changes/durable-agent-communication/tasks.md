# Tasks: Durable Agent Communication

## Review Workload Forecast

| Field | Value |
|---|---|
| Estimated authored changed lines | ~2,160 total; Slice 0 ~543; Phase slices 160–300 |
| Generated copies/goldens | ~300, tracked separately |
| 800-line review budget | Each slice fits; the feature does not fit one review |
| Suggested split | Slice 0 baseline, then one PR/work unit per phase, each targeting `main` after its predecessor merges |
| Delivery strategy / chain | chained PRs / stacked-to-main; no size exception |

Decision needed before apply: No
Chained PRs recommended: Yes
Chain strategy: stacked-to-main
400-line budget risk: High

Incident rationale: planning artifacts must be reviewed separately so every delivered file counts toward its slice's authored-line total. Slice 0 must merge before Phase 1 can be committed or pushed; Phase 2 is prohibited.

### Suggested Work Units

| Unit | Goal; focused test / runtime probe | Rollback boundary |
|---|---|---|
| 0 Planning Baseline | artifact presence/internal-consistency review; N/A—no runtime work | exact six planning files |
| 1 PRD | `python tests/prd_runtime_contract.py`; bootstrap fixture | PRD contract slice |
| 2 Proposal | `python tests/durable_agent_communication_contract.py --phase proposal`; bootstrap fixture | Proposal slice |
| 3 Spec | `python tests/durable_agent_communication_contract.py --phase spec`; bootstrap fixture | Spec slice |
| 4 Design | `python tests/durable_agent_communication_contract.py --phase design`; bootstrap fixture | Design slice |
| 5 Tasks | `python tests/durable_agent_communication_contract.py --phase tasks`; bootstrap fixture | Tasks slice |
| 6 Apply | `python tests/durable_agent_communication_contract.py --phase apply`; bootstrap fixture | Apply slice |
| 7 Verify | `python tests/durable_agent_communication_contract.py --phase verify`; bootstrap fixture | Verify slice |
| 8 Handoff | `python tests/durable_agent_communication_contract.py --phase handoff`; bootstrap fixture | Handoff slice |
| 9 Memory | `python tests/durable_agent_communication_contract.py --phase memory`; recovery fixture | Memory-maintenance slice |
| 10 Cleanup | `tests/smoke.sh audit-instructions`; wheel/bootstrap | shared cleanup slice |

Phase units append commands, artifact digests, Memory write outcomes, and runtime result to `apply-progress.md`; Slice 0 writes none and has no Phase 1 verify report. Verify preserves phase history, reopens an incomplete approved checkbox, and requires separately approved linked remediation. Revert the named whole slice before a dependent slice; never revert artifacts or Memory independently.

## Migration Order

Slice 0 → PRD → Proposal → Spec → Design → Tasks → Apply → Verify → Handoff → Memory maintenance → cleanup. Slice 0 establishes the review base; Handoff closes verified work, maintenance then migrates its standalone durable operation, and cleanup is safe only after no specialist needs legacy routing. Unmigrated phases stay unchanged; mixed operation, adapters, and dual authoritative contracts are forbidden.

`Atomic migration` below means compact launch, agent/skills/phase reference, six-field semantic response, durable artifact+Memory state, routing, package/generated equivalence, RED contract test, runtime fixture, and old-contract deletion only after accepted durable evidence.

## Slice 0: Planning Baseline
- [x] 0.1 Review only `openspec/config.yaml`, `exploration.md`, `proposal.md`, `specs/pegasus-harness-bootstrap/spec.md`, `design.md`, and `tasks.md` for approved internal consistency; no production/runtime PRD work, `apply-progress.md`, or `verify-phase-1-prd.md` belongs to this slice.

## Phase 1: PRD
- [ ] 1.1 RED `tests/prd_runtime_contract.py` and create `tests/durable_agent_communication_contract.py`: path-root, semantic-not-presentation response, no-envelope recovery, event/closure write failure, stale digest/relocation, and dedupe/superseding lineage; atomically migrate PRD and delete `results/prd-result-v1.md`.

Planning state: the previous Phase 1 attempt and file-based evidence are historical/quarantined, not active completion authority, and MUST NOT advance routing. Task 1.1 remains pending restoration, smoke remediation, and fresh verification after Slice 0.

## Phase 2: Proposal
- [ ] 2.1 RED phase fixture, apply Atomic migration, and delete `results/proposal-result-v1.md` after durable acceptance.

## Phase 3: Spec
- [ ] 3.1 RED phase fixture, apply Atomic migration, and delete `results/spec-result-v1.md` after durable acceptance.

## Phase 4: Design
- [ ] 4.1 RED phase fixture, apply Atomic migration, and delete `results/design-result-v1.md` after durable acceptance.

## Phase 5: Tasks
- [ ] 5.1 RED checkbox-only mutation/reconciliation fixture; apply Atomic migration and delete `results/tasks-result-v2.md` plus `tasks-transport-v2.md` after durable acceptance.

## Phase 6: Apply
- [ ] 6.1 RED cumulative-progress/recovery fixture; apply Atomic migration and delete `results/apply-result-v1.md` after durable acceptance.

## Phase 7: Verify
- [ ] 7.1 RED readiness/reopen-versus-approved-remediation fixture; apply Atomic migration and delete `results/verify-result-v1.md` after durable acceptance.

## Phase 8: Handoff
- [ ] 8.1 RED closure/handoff recovery fixture; apply Atomic migration and delete `results/handoff-result-v1.md` after durable acceptance.

## Phase 9: Memory Maintenance
- [ ] 9.1 RED observation/explicit-recovery fixture; apply Atomic migration and delete `results/memory-maintenance-result-v1.md` after durable acceptance.

## Phase 10: Terminal Cleanup
- [ ] 10.1 After phases 1–9 pass Verify, remove `shared/result-envelope.md`, `results/orchestrator-result-v1.md`, residual result contracts, and obsolete common routing; update AGENTS/Copilot/package expectations and prove source, bootstrap, and wheel equivalence.
