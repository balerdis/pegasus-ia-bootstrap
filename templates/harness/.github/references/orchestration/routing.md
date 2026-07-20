# Pegasus Orchestrator Routing Contract

## Scope And Authority

This manually loaded reference owns orchestration routing, dispatch, authorization, and returned-result validation only. It does not own specialist workflows, artifact internals, phase checks, execution, testing, installation, verification, or persistence operations.

## Route And Ownership

Use `request -> PRD -> proposal -> spec -> design -> tasks -> apply -> verify -> handoff`. Route PRD to `doc-designer`; the remaining phases route respectively to `sdd-proposal`, `sdd-spec`, `sdd-design`, `sdd-tasks`, `sdd-apply`, `sdd-verify`, and `session-handoff`. Every launch is one fresh specialist context. Apply and Verify are always distinct launches.

The coordinator may read only what is necessary to determine active change, current phase, in-file approval, launch identity, duplicate state, authorization, and strategy. It may validate returned transport and result fields, but MUST NOT inspect or reproduce specialist implementation procedures, reread artifacts to redo specialist validation, repair output, or perform specialist persistence.

Direct coordination is allowed only for a small mechanical routing task. It never includes a phase artifact, implementation, tests/builds/installs, verification, or persistence on behalf of a specialist. Outside SDD, required implementation or work needing four or more files, two or more non-trivial changed files, tests/builds/installs/external tooling, or more than mechanical coordination MUST use an authorized specialist; unavailable delegation blocks.

## Dispatch Gates

1. Read `.pegasus-bootstrap-ia/manifest.json` and require its `workspace.project_name` as the canonical project key. This generated workspace-owned field is authoritative; never derive or override it from a product title, user prose, target-path basename, PRD heading, or change ID. Missing, unreadable, invalid, ambiguous, or contradictory metadata blocks routing.
2. Resolve the active change and requested phase without exposing memory internals. Ambiguous recovered context does not authorize guessing.
3. Confirm required predecessor artifacts and their in-file approvals. Conversational approval cannot override a Draft, Pending, unchecked, or inconsistent artifact.
4. Derive launch identity deterministically. Every root PRD launch uses `<canonical-project-key>:prd:root`, including initial discovery, awaiting-input continuation, draft creation, material refinement, recovery, and review updates. Change-scoped identities are `<change-id>:<phase>` plus `:<task-slice-id>` for Apply. Aliases such as `root PRD`, title/prose labels, and path-name inference are invalid.
5. Establish duplicate state before dispatch from observable canonical project-scoped Pegasus Memory task/handoff state for that exact launch identity, artifact state, and current user intent. Apply additionally uses the authorized current-change artifact and `docs/pegasus/changes/<change-id>/apply-progress.md`. Missing state is not evidence of clearance; unavailable, stale, contradictory, or ambiguous evidence blocks. Never launch a duplicate.
6. Require explicit user approval before phase advancement. For Tasks, send the active change ID and fully expanded `docs/pegasus/changes/<change-id>/tasks.md` as separate routing data.
7. Before Apply, require exactly one approved task-slice identity and the current resolved delivery strategy. If forecast is over budget, High risk, recommends chaining, or requires a decision, ask the user to choose `stacked-to-main`, `feature-branch-chain`, or maintainer-approved `size:exception`. Historical preferences, defaults, inference, or tasks recommendations do not resolve strategy; `size:exception` also requires distinct maintainer approval. Unresolved strategy blocks Apply launch.
8. Dispatch exactly one matching specialist with explicit `project_key` and `launch_identity` payload fields. PRD payloads also identify root versus change-scoped persistence and the established duplicate state/evidence. If the agent tool or specialist is unavailable, launch fails, or no valid result returns, stop. Never transfer its ownership to the coordinator or another phase.

## Root PRD Duplicate And Refinement State

Derive exactly one state from the evidence named above and report that state plus its evidence; absence alone never clears the gate:

| State | Observable evidence | Allowed transition |
| --- | --- | --- |
| `not-started` | No root PRD work/progress record and the canonical root artifact is still the untouched template | Initial discovery launch |
| `awaiting-input` | Prior valid awaiting-input result or Memory state with unresolved questions, plus a later user answer or fresh authorized continuation | Fresh continuation under the same exact launch identity |
| `draft-refinement` | Existing root PRD has in-file `Draft`, the user explicitly requests its modification, and no concurrent/in-progress evidence exists | Fresh material-refinement or review-update launch under the same exact identity |
| `in-progress` | Current task/handoff or equivalent concurrent launch evidence | Block and recover or await; never dispatch |
| `approved/completed` | Consistent in-file approval/completion and Memory state | Block PRD rerun; no reopen policy is defined |
| `ambiguous/stale/contradictory` | Evidence cannot establish one consistent state | Block pending reconciliation |

These are lifecycle states for one stable launch identity, not aliases or new identities. Draft refinement preserves Draft unless the user separately supplies valid in-file approval; it never authorizes Proposal.

## Result Validation

Accept only observable launch evidence and the returned specialist envelope. Require the expected specialist identity, fresh-context delegation, canonical full artifact path when applicable, specialist ownership, truthful terminal operation states, risks/blockers, next action, and every field required by that specialist's result contract. Missing, partial, empty, duplicate, malformed, inconsistent, or unauthorized data blocks advancement.

For PRD, require returned `request_and_artifact` identity values to exactly match payload `project_key` and `launch_identity`; reject aliases or mismatch. Require the payload's established duplicate state/evidence in the result validation evidence. Validate the complete envelope against the PRD result contract's cross-field invariant, not field presence alone. A blocked awaiting-input result is valid only with concise questions, no artifact edit, and persistence `not needed: awaiting product input`; unresolved material decisions combined with any other status, edit/write, success/completion, approval-readiness, or approval-request action invalidate the result. If an observable material mutation occurred, reject `not needed`, file-only rationale, missing refresh, or persistence outcomes inconsistent with required `record_artifact` and `record_observation`. Surface valid questions unchanged and do not authorize Proposal. Any invalid PRD result makes the orchestrator outcome `blocked`; never request approval. `routed` is invalid with an unestablished duplicate gate, and every outcome still returns the orchestrator v1 envelope rather than prose.

For Design, require the complete canonical returned envelope, matching final/persistence revisions, exact `Post-persistence edits: none`, and terminal proposal-risk coverage state. Reproduce the valid envelope field-for-field with unchanged canonical labels and values, then ask exactly `¿Aprobás el diseño para avanzar a la fase de tareas?`. Do not reread Design or rerun its checks.

For Tasks, require exactly one canonical immutable v2 block, verify its SHA-256 and canonical JSON transport before decoding, validate the decoded full current-change tasks path, matching revisions, exact no-post-persistence-edit state, truthful persistence states, authorized strategy evidence, and no known duplicate handoff invocation. Copy a valid four-line block byte-for-byte; never reconstruct it. Invalid transport MUST block; do not ask strategy or launch apply. When its forecast requires a decision, ask exactly: `La previsión requiere definir la estrategia antes de apply. ¿Elegís \`stacked-to-main\`, \`feature-branch-chain\` o una excepción \`size:exception\` aprobada por el maintainer? No se iniciará apply hasta que respondas.`

Consume the Tasks forecast fields `Decision needed before apply`, `Chained PRs recommended`, `Chain strategy`, `400-line budget risk`, `Estimated authored changed lines`, `Estimated generated changed lines`, and `Tests included in estimate` only from the validated block.

For Apply and Verify, validate their existing versioned result envelopes without duplicating or weakening their phase contracts. Apply success authorizes only a distinct fresh Verify launch; Apply evidence never substitutes for Verify.

## Stable Boundaries

Artifacts remain change-scoped under `docs/pegasus/changes/<change-id>/`; root phase files are templates. Preserve useful progress/history by assigning merge behavior to the owning specialist. Artifact language defaults to English unless the user explicitly names another language for that artifact. Use one project-selected model without claiming hard per-phase routing or runtime parity.
