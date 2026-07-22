# Apply Progress: Durable Agent Communication

## R5 Invalidation, Supersession, And Corrective Rework

- The pre-R5 Phase 1 PRD success recorded below is retained as historical evidence only. R5 established that the integrated specialist identified six material product gaps, then edited `prd.md`, ensured/persisted Memory state, returned success, and was accepted for approval by routing. That behavior invalidates the former active-readiness conclusion.
- This corrective record supersedes the former Phase 1 success for specialist behavior. It preserves the prior commands, revisions, restoration evidence, and external quarantine history without treating them as authority to advance.
- Corrective tasks 1.1–1.3 are the active doc-designer-only rework. Tasks 1.4, R6, 1.5–1.6, R7, and Phases 2–10 remain pending; neither routing nor publication is changed by this slice.

## Current State

- Mode: Standard (strict TDD disabled).
- Completed tasks: 0.1, 1.1, 1.2, 1.3. Remaining tasks: 1.4, R6, 1.5–1.6, R7, and 2.1–10.1.
- Current slice: Phase 1 corrective doc-designer rework, stacked-to-main PR 1, based on merged Phase 1 `38ffb53a31ff50330b40e2e28f657f0498cb0935`.
- Advancement: this specialist-only slice does not establish routing readiness. R6 remains the required direct operational gate; Phase 2 was not started.

## Restoration And Remediation

- Historical Phase 1 work was quarantined after fresh Verify found an unauthorized-path smoke failure; task 1.1 was reopened without discarding its history.
- The approved backup `pegasus-slice0-separation-20260721-dLL18A` was verified with `sha256sum -c SHA256SUMS`: tracked patch plus all five untracked payloads passed.
- Restoration used `git apply --check`, `git apply`, and copies of only the manifest's five untracked Phase 1 paths. The historical failing `verify-phase-1-prd.md` was not retained as active evidence; the verified external backup preserves it.
- `tests/smoke.sh` now explicitly allows only this active change's `openspec/changes/durable-agent-communication/apply-progress.md`; the unauthorized-untracked negative probe and every other protected-path restriction remain enforced.

## Work Unit Evidence

| Evidence | Result |
|---|---|
| RED contract | Historical RED: `python3 tests/prd_runtime_contract.py` failed before implementation because `shared/semantic-response.md` was absent (exit 1). |
| Focused tests | `python3 tests/prd_runtime_contract.py && python3 tests/durable_agent_communication_contract.py --phase prd` — exit 0; both probes passed. |
| Instruction audit | `python3 tests/audit_instruction_architecture.py` — exit 0; 55 instruction files, 29 reachable references, 0 broken/orphan/cycle/package/generated mismatches. |
| Runtime harness | The PRD runtime probe bootstrapped an isolated relocated workspace and validated generated PRD references and legacy-contract deletion — exit 0. |
| Audit harness | `timeout 300s bash tests/smoke.sh audit-instructions` — exit 0; 12 negative self-tests passed. |
| Package harness | `timeout 300s bash tests/smoke.sh wheel` — exit 0; wheel reference equivalence passed. |
| Full regression | `timeout 600s bash tests/smoke.sh` — exit 0; source/generated/package equivalence and smoke suite passed after the path-guard remediation. |
| Rollback boundary | Revert the complete PRD slice file set below, restore `results/prd-result-v1.md` and its package/test expectations, and reopen task 1.1. Do not revert artifacts or Memory records independently after a dependent slice starts. |

## Corrective Doc-Designer Work Unit Evidence

| Evidence | Result |
|---|---|
| RED contract | `timeout 120s python3 tests/doc_designer_contract.py` — exit 1 before the correction: the macro lacked `execution-specific compact launch brief`. |
| GREEN specialist contracts | `timeout 180s python3 tests/doc_designer_contract.py && timeout 180s python3 tests/prd_runtime_contract.py` — exit 0; direct material-gap blocking, compact specialist boundary, relocated bootstrap, and generated PRD assets passed. |
| Instruction architecture | `python3 tests/audit_instruction_architecture.py` — exit 0; 55 instruction files, 29 reachable references, 0 broken/orphan/cycle/package/generated mismatches. |
| Runtime harness | `timeout 300s bash tests/smoke.sh audit-instructions` — exit 0; specialist contract probes and instruction self-audit passed. |
| Package harness | `timeout 300s bash tests/smoke.sh wheel` — exit 0; wheel reference equivalence passed. |
| Diff hygiene | `git diff --check` — exit 0. |
| Rollback boundary | Revert only `doc-designer.agent.md`, `phases/prd.md`, `tests/doc_designer_contract.py`, and `tests/prd_runtime_contract.py`, then reopen 1.2–1.3. Keep R5 lineage and this cumulative progress record; do not revert routing, R6/R7, publication, or later-phase state because none belongs to this work unit. |

## Corrective Artifact Revisions And Memory Outcomes

- `templates/harness/.github/agents/doc-designer.agent.md`: SHA-256 `722977042b8319a3b6100798d7926cdcfb94ad248f23748372a82637a7fd7705`.
- `templates/harness/.github/references/phases/prd.md`: SHA-256 `29e5cafc448c947d0613d83add05d99deb8a448289ae5534e76ae781265e2b4c`.
- `tests/doc_designer_contract.py`: SHA-256 `ee8e0fc61ae6c362c9f4d544b65f066e7f43e84d919bfb4bb942371bb45419de`.
- `tests/prd_runtime_contract.py`: SHA-256 `722063b909d8bd73ea73bdfb1f081ea0c21bd1a83bf35726b0b80674f91c1e66`.
- Pegasus Memory preserves the R5 regression at `bugfix/prd-material-gap-runtime-gate`; `sdd/durable-agent-communication/tasks` and `sdd/durable-agent-communication/apply-progress` are refreshed with this corrective revision. The superseded pre-R5 conclusion remains historical, not active readiness.

## Changed Files

- `tests/prd_runtime_contract.py` — replaced envelope probes with bootstrap relocation/generated PRD migration coverage.
- `tests/durable_agent_communication_contract.py` — added semantic handles, independent statuses, failure, relocation, and observation-lineage probes.
- `tests/smoke.sh` — added migrated PRD/package/graph expectations and allows only the active authorized OpenSpec apply-progress artifact while preserving all other protected-path checks.
- `templates/harness/.github/agents/doc-designer.agent.md` — compact launch gate and focused lazy references.
- `templates/harness/.github/references/orchestration/routing.md` — compact PRD dispatch, no-envelope continuity, semantic/evidence validation.
- `templates/harness/.github/references/phases/prd.md` — relative SHA-256 handles and event/closure persistence flow.
- `templates/harness/.github/references/shared/persistence.md` — migrated-phase required-write advancement gate.
- `templates/harness/.github/references/shared/semantic-response.md` — canonical six-field disposable response.
- `templates/harness/.github/references/shared/durable-state.md` — canonical identity, digest, lineage, failure, and recovery contract.
- `templates/harness/.github/references/results/prd-result-v1.md` — deleted after runtime, generated, and wheel evidence passed.
- `templates/harness/docs/pegasus/tasks.md` — controlled-mutable task authority.
- `templates/harness/docs/pegasus/apply-progress.md` — cumulative evidence authority.
- `templates/harness/docs/pegasus/verify.md` — readiness and checkbox reconciliation authority.
- `pyproject.toml` — removed only the PRD legacy result from package data; shared and later-phase contracts remain.
- `openspec/changes/durable-agent-communication/tasks.md` — marked only task 1.1 complete after passing evidence.
- `openspec/changes/durable-agent-communication/apply-progress.md` — merged historical attempt and restoration/remediation evidence.

## Durable Outcomes

- OpenSpec task/progress writes: complete. Pegasus Memory task/progress writes use the stable `sdd/durable-agent-communication/{tasks,apply-progress}` topics; task state does not replace Verify authority.
- Material observation: the historical smoke guard treated an authorized current-change progress artifact as contamination; this remediation resolves that authorization gap without widening the allowlist.
- Artifact identity: SHA-256 relative handles: `doc-designer.agent.md` `722987cb4cfe052a5a5625802cc34ae8c0900509abe5d2b70b44b42b56d92b99`; `routing.md` `e2ff39d0804878bf61f1b1d89abdb1b7dd55159ede82e16d7584abe7b2901bde`; `prd.md` `f861c2aec1c0e1e302d940e746207a89535461a50ec427a33dfa02d98c038b52`; `durable-state.md` `0770cd3535616ce96fc1efbc9eb2cbfc3937d20042b6d36fcc97ba2ec5e8970a`; `semantic-response.md` `262235dcc9f1a5611e97b8e7798300f5db20a598943bb8f819620bafa7e0c15e`; `prd_runtime_contract.py` `987e86feb5da8233f2a22a07caf39c7e5291c85dd85e1c3d1c33bc1ddea67672`; `durable_agent_communication_contract.py` `7b7c7ada66f40f5d089cb48e33997822f2106ededc985941302c8fe99a9e0f46`.

## Deviations And Blockers

- Deviations: none; the smoke-guard change is the minimal remediation authorized for the current-change apply-progress artifact.
- Blockers: none in Apply. Verify remains a separate required phase.

## Verification Evidence: verify-phase-1-prd

Supersedes the historical failed Phase 1 report retained only in the verified external quarantine backup. This is Phase 1 / task 1.1 evidence only; it does not verify the full change or authorize Phase 2.

```yaml
schema: gentle-ai.verify-result/v1
evidence_revision: sha256:2785e55f3982471143a43b56740f8efd5ab0e81dfd2623f33eee6648e845c314
verdict: pass
blockers: 0
critical_findings: 0
requirements: 6/6
scenarios: 11/11
test_command: timeout 600s bash tests/smoke.sh
test_exit_code: 0
test_output_hash: sha256:e4387273a8d1aed99996852f80e084c675fa36d5dfe78a16f9647baecfa46608
build_command: timeout 300s bash tests/smoke.sh wheel
build_exit_code: 0
build_output_hash: sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
```

- Focused runtime: `timeout 180s python3 tests/prd_runtime_contract.py` — exit 0; SHA-256 `5f4a63af6a60585e07744b8cc0b6fbd97055e3b5058c121f309748eb3696bde3`.
- Focused semantic: `timeout 120s python3 tests/durable_agent_communication_contract.py --phase prd` — exit 0; SHA-256 `e68c3dce489e735d01ea0cad9d94d579e03806aa5357d9f5f51f1efb0ea428f7`.
- Architecture audit: `timeout 240s python3 tests/audit_instruction_architecture.py` — exit 0; SHA-256 `249eb9d69792f7ef28e1baaef23be845d586454b4145617732786dbff13981e3`.
- Instruction self-audit: `timeout 300s bash tests/smoke.sh audit-instructions` — exit 0; SHA-256 `c4b9b8e8ab41ce453815160e098c7a6d6fcc609cb57ee76b2c9a39ae464d9b8d`.
- Diff hygiene: `git diff --check 8a0616264bff09a46fc6dcc2cb91940e0d1ab38e` — exit 0.
- Review impact at the executed evidence revision: 302 additions + 383 deletions = 685 authored changed lines, within the 800-line budget. The restricted untracked `install_and_usage.txt` was not read or modified.
- The protected-path guard allows only the active current-change `apply-progress.md`; its negative unauthorized-untracked probe passed. No generated or later-phase contract leakage was found; source/bootstrap/wheel equivalence passed.
