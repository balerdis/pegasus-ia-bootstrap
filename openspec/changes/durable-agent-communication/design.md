# Design: Durable Agent Communication

## Technical Approach

Migrate one phase vertically, beginning with PRD, from stateful versioned envelopes to compact launches, six-field semantic responses, artifact authority, and Pegasus Memory continuity. Templates remain canonical; installed workspaces and wheels are generated products. No global prompt grows: macros retain identity, authorization, exact lazy-load gates, precedence, and truthful-result gates; focused references own transport, persistence, schemas, recovery, and reconciliation.

## Ownership and Decisions

| Concern | Canonical owner / decision | Rationale and rejected alternative |
|---|---|---|
| Launch | Orchestrator + `references/orchestration/routing.md` construct execution facts only: `objective`, `current_intent`, `identity`, `artifact_store`, `context`, `expected_outputs`, `response_focus`, `detail_level`, `skills`, `constraints`. | Prevent policy duplication; reject architecture/recovery matrices in launches. |
| Specialist behavior | Agent macro owns role/gates; phase reference owns workflow; focused shared references own durable state and semantic response. | Preserve lazy loading; reject another large eager/global prompt. |
| Immediate response | Shared response reference defines required fields; routing validates meaning/evidence, not ordering, Markdown shape, or exact prose. | `status ∈ {success,partial,blocked}` and independent `durable_state_written ∈ {complete,partial,not-written,not-required}`; reject presentation-exact envelopes. |
| Durable authority | OpenSpec/phase artifacts own truth; Pegasus Memory indexes summaries, blockers, next action, and revisions; visual TODO is session-only. | Reject prior responses, TODOs, adapters, or Memory as co-authority. |
| Implementation state | `tasks.md` owns approved text/order and mutable checkboxes only; `apply-progress.md` appends attempts/evidence; `verify.md` alone owns readiness/archive/delivery. | Verify reopens an original checkbox when approved scope is incomplete; genuinely new remediation requires separate approval and linked Verify evidence. |

## Durable Contracts

Stable key is `{project, work_scope, phase?, slice?}` where `work_scope` is `root`, `change:<id>`, or `point:<id>`. `session_id`, `attempt_id`, `retry`, actor, and timestamps are append-only metadata, never key dimensions.

`observation = {identity, semantic_topic, category, conclusion, evidence_digest, revision, active}`. Identical identity+digest merges; changed conclusions append a revision and relation. `relation = {from_revision, type: supersedes|resolves|related_to|caused_by, to_revision}`. Progress, handoff, and artifact-index records upsert by stable key while preserving attempt history.

`artifact_ref = {identity, relative_path|durable_topic, algorithm: sha256, digest, git_commit?}`. A multi-file manifest is UTF-8 lines sorted lexicographically by normalized relative path, each `<path>\t<sha256>\n`; its SHA-256 is the logical revision. Absolute roots and timestamps cannot establish revision.

## Persistence and Recovery Flow

```text
launch exact handles → validate manifest/identity → proportional reads → execute
  → material event: write observation immediately (failure: preserve files, blocked/not-written)
  → finalize/read back artifacts → hash references/manifest
  → before response: write progress + handoff + phase/next-action + summary + refs
  → semantic response → orchestrator advances only from current durable evidence
```

There is no silent retry or Markdown fallback. Any required Memory failure blocks advancement; an explicit recovery launch reuses the stable identity and receives current user intent plus exact artifact/topic/status handles. Specialists reject stale/non-canonical handles and never scan the full store or reconstruct generic architecture.

## Affected Surfaces and Source Ownership

| Surface | Change |
|---|---|
| `templates/harness/.github/agents/{pegasus-orchestrator,doc-designer}.agent.md` | Compact PRD gates/loads; remove envelope dependencies. |
| `templates/harness/.github/references/{orchestration/routing,shared/persistence,shared/status-readiness,phases/prd}.md` | Route from durable evidence; event/closure sequencing and reconciliation. |
| `templates/harness/.github/references/shared/semantic-response.md`, `durable-state.md` | Add focused canonical contracts. |
| `templates/harness/.github/references/results/prd-result-v1.md` | Delete in accepted PRD slice. Later phase slices delete their own result files. |
| `templates/harness/docs/pegasus/{tasks,apply-progress,verify}.md` | Encode authority/reconciliation. |
| `pyproject.toml`, `tests/audit_instruction_architecture.py`, `tests/prd_runtime_contract.py`, `tests/smoke.sh` | Package new references; test source, generated workspace, wheel, semantic states, digests, failures, and no forbidden reads. |

Never edit `build/` copies; regenerate via wheel/bootstrap. Template changes must remain byte-equivalent after rendering and pass instruction graph/budget audits.

## Migration, Rollback, and Observability

Order: PRD, then each remaining phase as an atomic launch+specialist+durable-state+routing+test slice. Accept durable evidence before deleting that phase’s old contract. Unmigrated phases remain unchanged, but mixed-state ecosystem operation is unsupported; no adapter or dual contract. After every phase migrates, a terminal slice deletes `shared/result-envelope.md`, residual result versions, and obsolete routing. Roll back only an entire phase slice before dependent slices; never roll back artifacts/Memory independently. Observe identity, attempt, event/closure write outcomes, artifact/manifest digests, stale-reference rejection, blocker, and advancement decision without storing response transcripts.

## Testing and Threat Matrix

RED contract tests cover compact launch rejection, independent status domains, duplicate/superseding observations, deterministic manifests/relocation, task-text mutation rejection, Verify reopening/remediation approval, event/closure Memory failures, explicit recovery, generated/wheel equivalence, and phase-contract deletion gates.

| Boundary | Applicability | Design response / RED tests |
|---|---|---|
| Documentation-like paths | N/A: no executable classification | None. |
| Git repository selection | N/A: Git metadata is optional data only | None. |
| Commit state | N/A: no commit automation | None. |
| Push state | N/A: no push automation | None. |
| PR commands | N/A: no PR command construction | None. |

## Open Questions

None.
