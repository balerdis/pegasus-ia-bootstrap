# Durable Agent Communication — Exploration Decision Map

## Exploration status

Discovery only. This document records confirmed evidence, decisions to refine, and product/architecture questions. It is not a PRD, proposal, specification, design, task plan, or implementation authorization.

## Current State

Pegasus currently distributes phase behavior over a thin agent macro plus ordered shared, phase, and versioned-result references. This protects ownership and exact contracts, but a fresh specialist can need roughly 9–10 reads before work. The R4 incident showed that this is vulnerable to path transcription and cognitive overload.

Result schemas are phase-specific and carry substantial workflow evidence. `PEGASUS_APPLY_RESULT_V1`, for example, transports changed files, preliminary checks, progress updates, persistence, and next action. There is no canonical `executive_summary` field. The orchestrator itself eagerly requires `shared/result-envelope.md`, and routing treats prior valid results as duplicate/continuation evidence. That creates a risk that an immediate transport envelope becomes de facto recovery state.

Artifacts now have a confirmed durable split: `tasks.md` holds the approved implementation plan and canonical per-task completion checkboxes; `apply-progress.md` is the detailed cumulative implementation evidence; and `verify.md` is the source of truth for verification evidence and verdicts. Pegasus Memory is the compact recovery index/mirror for their identities, revisions, summaries, blockers, and next action. Its canonical upsert hierarchy is project → work scope → phase → optional slice, while retry/session/attempt IDs remain append-only audit metadata. The orchestrator's visual/session TODO list is temporary coordination only and has no durable authority.

## Affected Areas

- `templates/harness/.github/agents/pegasus-orchestrator.agent.md` — current eager result-envelope load and launch-identity gate.
- `templates/harness/.github/references/orchestration/routing.md` — duplicate/recovery logic currently accepts prior result evidence and defines dispatch payloads.
- `templates/harness/.github/references/shared/result-envelope.md` — generic immediate-result contract with no executive summary.
- `templates/harness/.github/references/shared/persistence.md` — durable recovery/write behavior and artifact-refresh rule.
- `templates/harness/.github/references/phases/tasks.md` and `phases/apply.md` — planned versus actual implementation tracking.
- `templates/harness/.github/references/results/*.md` — phase-specific transport schemas, especially Apply and Tasks v2.
- `templates/harness/docs/pegasus/tasks.md`, `apply-progress.md`, and `verify.md` — file authority for plan, implementation evidence, and verification.
- `openspec/specs/pegasus-harness-bootstrap/spec.md` — existing product requirements state that files are truth and Pegasus Memory references/summarizes them.

## Decision Map

### 1. Small self-contained invocation

| Confirmed decisions | Open questions | Tradeoffs | Non-goals |
| --- | --- | --- | --- |
| The compact launch describes this execution only: `objective`, `current_intent`, `identity` (project, work scope, optional phase/slice), artifact-store mode, exact required context handles, expected outputs, response focus, relevant detail level, pre-resolved skills, and exceptional constraints. Normal authorization, read/recovery behavior, persistence timing, and response framework belong to the specialist skill plus focused lazy-loaded references. | None. | A compact execution-specific launch eliminates repetitive generic policy; it depends on specialists receiving correct skill/reference contracts and structured handles. | Repeating generic allowed/forbidden lists, per-call context-read/persistence matrices, or the complete architecture in every launch. |

#### Confirmed compact launch contract

| Field | Purpose |
| --- | --- |
| `objective` | Concrete work to perform now. |
| `current_intent` | Current user intent for this execution. |
| `identity` | `project`, `work_scope`, optional `phase`, optional `slice`. |
| `artifact_store` | Store mode for this execution. |
| `context` | Exact artifact/topic/status handles required now; machine-provided structured handles are consumed, not reconstructed. |
| `expected_outputs` | Concrete artifacts/results expected from this execution. |
| `response_focus` | What the orchestrator needs summarized for its next decision. |
| `detail_level` | `concise`, `standard`, or `deep` when relevant. |
| `skills` | Exact pre-resolved skill paths. |
| `constraints` | Exceptional execution-specific limits only: edit roots, no commit/push, assigned slice, approved delivery strategy, and similar constraints. |

The shared response framework is known from the specialist skill and is not repeated in launches: `status`, `executive_summary`, `artifacts`, `durable_state_written`, `next_recommended`, and `risks`. A detailed phase-owned report is optional when needed. Response validation is semantic and evidence-based, never byte/order/phrase exact.

**Boundary to preserve:** manifest validation remains mandatory where canonical project identity matters. The manifest is identity/ownership metadata, not operational state.

### 2. Minimal ephemeral response

| Confirmed decisions | Open questions | Tradeoffs | Non-goals |
| --- | --- | --- | --- |
| Normalize immediate transport around `status`, `executive_summary`, `artifacts`, `durable_state_written`, `next_recommended`, and `risks`. It is for the caller now, never for a later continuation. `status` reports execution state; `durable_state_written` independently reports persistence outcome. On material-memory persistence failure, the response may be delivered but MUST report `status: blocked`, `durable_state_written: not-written`, and the blocker in both `executive_summary` and `risks`. Migrate this vertically phase by phase, beginning with PRD; each migrated phase removes its old phase-specific result contract with no adapter, translation layer, or dual authority. | None. | Separate vocabularies prevent a completed response from falsely implying durable closure or workflow authorization. | Using a result transcript as a handoff, duplicate gate, recovery database, artifact substitute, adapter, dual authoritative contract, or a single status to infer advancement. |

#### Confirmed result status semantics

| Field | Values | Meaning |
| --- | --- | --- |
| `status` | `success`, `partial`, `blocked` | `success`: assigned execution objective achieved only; it does not imply artifact approval, verification pass, or authorization to advance. `partial`: valid work/progress exists but the objective or durable closure is incomplete. `blocked`: safe completion is prevented by missing input, authorization, dependency, contradictory state, or equivalent blocker. |
| `durable_state_written` | `complete`, `partial`, `not-written`, `not-required` | `complete`: every required durable write succeeded. `partial`: only some required writes succeeded. `not-written`: writes were required but none succeeded. `not-required`: this invocation had no durable-write obligation. |

Examples: PRD awaiting material answers before any write is `blocked` + `not-required`; a valid implementation with failed handoff/closure is `partial` + `partial` or `not-written` according to actual writes; a stateless audit is `success` + `not-required`; a completed and fully persisted phase is `success` + `complete`. Workflow advancement is never inferred from `status` alone: the orchestrator uses `next_recommended` plus current durable state/artifacts.

**Contradiction with current behavior:** the orchestrator must load `result-envelope.md` before any dispatch and routing accepts a prior valid result as `awaiting-input` evidence. Both conflict with a transport-only response and require migration away from envelope-based continuity.

### 3. Durable authority and implementation tracking

| Confirmed decisions | Open questions | Tradeoffs | Non-goals |
| --- | --- | --- | --- |
| No single artifact owns every terminal-state dimension. `tasks.md` is controlled-mutable authority for current task completion/pending work; `apply-progress.md` is cumulative historical execution evidence and never hides failed attempts; `verify.md` is acceptance/readiness authority and controls advancement, archive, and delivery eligibility. Pegasus Memory summarizes combined current state plus exact revisions/paths for routing, never overriding artifact authority. Artifact references use canonical identity, workspace-relative location or durable topic, and a SHA-256 content digest; optional Git commits and timestamps are traceability metadata only. | None. | Content digests are portable and detect staleness without copying bodies; multi-file artifacts require a deterministic manifest. | Stateful result envelopes; a second full implementation log in Memory; regenerated absolute workspace roots; Git commits or timestamps as revision authority; rewriting Apply history to hide failed attempts; exposing another product's terminology or dependencies in generated Pegasus assets. |

#### Mapping the requested durable implementation-tracking style to Pegasus

| Concern | Canonical authority | Pegasus Memory mirror | Immediate response |
| --- | --- | --- | --- |
| Approved implementation plan, slice order, scope, forecast, rollback, and current canonical task completion/pending state | `docs/pegasus/changes/<id>/tasks.md` (controlled-mutable checkboxes only) | active plan path, revision, phase status, next approved slice | artifact reference only |
| Actual slice start, changed files, preliminary commands/results, deviations, blockers | `apply-progress.md` (append/merge by slice) | slice status, compact summary, blockers, handoff, apply-progress revision/path | compact summary only |
| Acceptance checks, failures, final verdict, caveats, and advancement/archive/delivery eligibility | `verify.md` (append/merge evidence) | verify status, outcome summary, unresolved risk, revision/path | compact summary only |
| Product/technical decisions, discoveries, fixes, restrictions | approved source artifact where it changes product/technical truth; otherwise a durable Memory observation | decision/discovery/fix record linked to change and affected artifact revision when applicable | mention only if relevant now |

This answers the tracking question without stateful envelopes: `tasks.md` states **what is authorized and what work is currently complete or pending**; `apply-progress.md` states **the detailed cumulative execution evidence**; `verify.md` states **what was proven and whether advancement is eligible**. Pegasus Memory indexes and summarizes the latest durable state for recovery. A response merely confirms which durable records were written and what to do next. The orchestrator's visual/session TODO list may assist the current session but cannot create, alter, or supersede durable state.

#### Verify-failure reconciliation

1. Preserve Apply history and block advancement through the Verify verdict.
2. When the same approved scope remains incomplete, reopen the original `tasks.md` checkbox.
3. When Verify reveals genuinely new work, add a separately approved remediation task; do not silently mutate the original scope.
4. Record reason and evidence linking the Verify outcome to the reopened or new task.

#### Confirmed portable artifact-reference model

- Store canonical artifact identity and workspace-relative location/path or stable durable topic; never store a regenerated absolute workspace root.
- Record revision algorithm `sha256` and the digest over exact persisted content.
- A Git commit may be recorded when committed, only for traceability; timestamps are metadata only. Neither replaces the digest.
- For logical multi-file artifacts, create a canonical ordered manifest of relative path plus digest, then hash that manifest.
- Agents compare the stored digest with current authoritative content to detect staleness without duplicating artifact bodies.

### 4. Persistence timing and stable identity

| Confirmed decisions | Open questions | Tradeoffs | Non-goals |
| --- | --- | --- | --- |
| Persist material discoveries, fixes, decisions, restrictions, and blockers immediately when they occur. Before execution closure, persist a session/execution summary, phase status, next action, and exact artifact references/revisions. Progress, handoff, and artifact-index records upsert/merge under the canonical hierarchy: required project → `work_scope` (`root`, `change:<id>`, or `point:<id>`) → phase when phase-oriented → optional slice only when it exists. Retry/session/attempt IDs are append-only audit metadata, never key dimensions. Material observations use append-only revisions, explicit lineage, semantic identity, and evidence digest deduplication. On a material persistence failure, preserve current artifact state, return a truthful blocked response, surface the blocker, and prohibit workflow continuation until explicit durable recovery/persistence resolves it; a later explicit operation may retry under the same identity. | None. | Explicit lineage preserves auditability and prevents duplicate active conclusions; it requires relation-aware persistence. | Silently retrying indefinitely, claiming durable success, discarding the blocker, creating a Markdown fallback/co-source, overwriting contradictory conclusions, or exposing duplicate active truth. |

#### Confirmed identity and observation model

| Record type | Stable identity | Update behavior |
| --- | --- | --- |
| Progress, handoff, artifact index | `project` → `work_scope` → phase when relevant → slice when present | Upsert/merge under the hierarchy; attach retry/session/attempt data as append-only audit metadata. |
| Root discovery | `project` → `root` | Omit change and slice; include phase only when the work is phase-oriented. |
| Change work | `project` → `change:<id>` → phase when relevant → slice when present | Preserve stable continuity across retries and sessions. |
| Point task | `project` → `point:<id>` | May omit phase and artifact access when neither is relevant. |
| Material observation | hierarchy above plus stable semantic topic/category identity | Distinct discoveries, fixes, decisions, and restrictions do not overwrite each other; updates to the same topic merge or explicitly supersede. |

#### Confirmed material-observation lifecycle

1. Create a separate observation for each semantically new material discovery, fix, decision, restriction, or blocker. A discovery and its fix remain distinct records linked as `fix resolves discovery`.
2. Upsert/merge under the same stable semantic identity only when evidence expands or confirms the same conclusion, adds affected artifacts/tests/revisions, or updates progress without changing meaning.
3. When a new conclusion replaces an old one, create a new append-only revision, mark the old revision superseded, link `new supersedes old`, and expose only the new revision as active truth.
4. Deduplicate identical retries with stable identity plus content/evidence digest.
5. Minimum relations are `supersedes`, `resolves`, `related_to`, and `caused_by`. Preserve history and never overwrite contradictory prior conclusions without lineage.

#### Confirmed partial-blocking policy

1. On a material discovery or restriction, attempt immediate Pegasus Memory persistence.
2. If it fails, preserve the current artifact state and deliver a truthful immediate response with `status: blocked` and `durable_state_written: not-written`.
3. The immediate response MUST name the blocker in `executive_summary` and `risks`; the orchestrator surfaces it and blocks phase/workflow continuation.
4. Result delivery and durable closure are separate: delivery may finish while workflow status remains blocked.
5. Only an explicit later recovery operation may retry persistence, under the same stable hierarchical identity. No indefinite silent retry or Markdown fallback is permitted.

#### Lifecycle moments and required authority

| Moment | Artifact authority | Pegasus Memory authority | Response role |
| --- | --- | --- | --- |
| Invocation preflight | existing authorized inputs, when declared | recover only if continuity is declared relevant | declare scope and expected outputs |
| Material semantic occurrence | update artifact only if it changes documented truth | immediately attempt merge under stable identity; failure blocks durable closure | deliver blocked status with `durable_state_written: not-written`, plus blocker in summary and risks |
| Slice execution transition | `apply-progress.md` records actual work | progress status, blocker, and handoff summary | status only |
| Artifact finalization | finalized artifact and frozen revision | artifact location/revision plus concise summary | `durable_state_written` reports outcome |
| Execution/session closure | source artifacts retain detailed history | phase status, next action, blockers, exact references/revisions, handoff summary | `next_recommended` only |

### 5. Proportional recovery

| Confirmed decisions | Open questions | Tradeoffs | Non-goals |
| --- | --- | --- | --- |
| Read dependencies and persistence obligations are distinct shared-policy concerns, not repeated launch matrices. The orchestrator supplies only the exact context handles this execution needs; specialists validate them and do not defensively reconstruct all stores/workflow. Event-driven material persistence still applies when authorized and Pegasus Memory is available, independently of initial read needs. | None. | Separating reads from writes prevents needless recovery and avoids hiding durable-close obligations; compact launches require the shared policy contracts to be correctly loaded. | A single `none|memory|artifacts|both` enum; per-call context-read/persistence matrices; defensive full-architecture reconstruction; assuming a prior chat/result exists; treating Memory availability as a substitute for artifact authority. |

#### Confirmed launch-policy model

| Policy area | Declaration | Allowed values |
| --- | --- | --- |
| `context_reads` | `manifest` | `required` or `not-needed` |
| `context_reads` | `pegasus_memory` | `required`, `conditional`, or `not-needed` |
| `context_reads` | `artifacts` | exact paths/identities or `not-needed` |
| `persistence` | `observations` | `event-driven` or `not-needed` |
| `persistence` | `progress` | `required-before-close` or `not-needed` |
| `persistence` | `handoff` | `required-before-close` or `not-needed` |
| `persistence` | `artifact_writes` | exact allowed paths or `none` |

Every `not-needed` declaration requires observable invocation facts, such as a self-contained task, no continuity requirement, no authorized mutation, or no relevant existing artifact. Read dependencies do not suppress authorized event-driven persistence; write obligations do not imply an initial recovery read.

## Confirmed Migration Strategy

1. Migrate vertically, one phase end-to-end at a time, starting with PRD and then sweeping every remaining phase.
2. Each phase slice updates together: orchestrator launch payload, specialist contract/behavior, minimal result, durable artifact/Pegasus Memory state, routing validation, and tests.
3. Once a phase migrates, remove its old phase-specific result contract. No adapter, translation layer, or dual authoritative contract is permitted for that phase.
4. Unmigrated phases continue unchanged until their own vertical slices.
5. Every vertical slice remains independently reviewable and preserves workflow correctness.
6. After all phases migrate, execute a separate terminal cleanup slice: delete `shared/result-envelope.md`, remove remaining old versioned result contracts, and simplify common routing.

## Direction Under Refinement

The confirmed phase-by-phase vertical migration preserves artifact truth, gives Memory durable continuity, and makes immediate responses intentionally disposable without adapters or dual authority. This is a discovery direction, not approval to propose or implement.

## Migration Risks

- Current macros require long ordered reference lists; replacing them without preserving fail-closed identity/authorization gates could weaken safety.
- Each migrated phase must replace its detailed result contract atomically across launch, specialist, durable state, routing, and tests; partial phase conversion would create an invalid contract gap.
- Orchestrator launch-policy classification must remain explicit: a `not-needed` read declaration cannot silently suppress a required-before-close persistence obligation.
- Final shared-result and common-routing deletion must wait until every phase is migrated and remain a separate terminal reviewable slice.
- Existing duplicate-state logic relies partly on prior result evidence; migration must establish durable Memory/artifact equivalents before removing that fallback.
- Stable hierarchy must be applied consistently to progress, handoff, artifact-index, and observation records; retry metadata must not fragment active state.
- A failed material persistence write must remain visible and block continuation until an explicit retry resolves it; recovery tooling must not create an unbounded retry loop.
- Controlled task-checkbox updates must be distinguishable from task-text/scope replanning so a completion update cannot silently alter authorization.
- Artifact revision references must update atomically enough that Memory summaries do not point to stale content after artifact edits.
- Public generated Pegasus content must remain neutral: no public dependency on, or mention of, external product names; use Pegasus Memory and artifact contracts.
- The configured review budget is 800 lines. Any future implementation should be sliced and forecast against that budget; this exploration does not authorize a delivery plan.

## Ready for Proposal

Yes. The original five-pillar decision set is ready for final user review. This remains discovery only; no proposal, specification, design, tasks, or implementation is authorized by this readiness state.
