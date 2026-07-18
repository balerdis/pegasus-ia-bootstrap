# Pegasus Orchestrator Routing Contract

## Scope And Authority

This manually loaded reference owns orchestration routing, dispatch, authorization, and returned-result validation only. It does not own specialist workflows, artifact internals, phase checks, execution, testing, installation, verification, or persistence operations.

## Route And Ownership

Use `request -> PRD -> proposal -> spec -> design -> tasks -> apply -> verify -> handoff`. Route PRD to `doc-designer`; the remaining phases route respectively to `sdd-proposal`, `sdd-spec`, `sdd-design`, `sdd-tasks`, `sdd-apply`, `sdd-verify`, and `session-handoff`. Every launch is one fresh specialist context. Apply and Verify are always distinct launches.

The coordinator may read only what is necessary to determine active change, current phase, in-file approval, launch identity, duplicate state, authorization, and strategy. It may validate returned transport and result fields, but MUST NOT inspect or reproduce specialist implementation procedures, reread artifacts to redo specialist validation, repair output, or perform specialist persistence.

Direct coordination is allowed only for a small mechanical routing task. It never includes a phase artifact, implementation, tests/builds/installs, verification, or persistence on behalf of a specialist. Outside SDD, required implementation or work needing four or more files, two or more non-trivial changed files, tests/builds/installs/external tooling, or more than mechanical coordination MUST use an authorized specialist; unavailable delegation blocks.

## Dispatch Gates

1. Resolve the active change and requested phase without exposing memory internals. Ambiguous recovered context does not authorize guessing.
2. Confirm required predecessor artifacts and their in-file approvals. Conversational approval cannot override a Draft, Pending, unchecked, or inconsistent artifact.
3. Apply the macro's mandatory pre-dispatch duplicate gate. Derive launch identity from change ID plus phase and, for Apply, task-slice ID. Canonical allowed state is MCP task progress and `docs/pegasus/changes/<change-id>/apply-progress.md`; use only state authorized for the active route. An in-progress identity must be recovered or awaited; a completed identity routes to the next authorized boundary. Never launch a duplicate.
4. Require explicit user approval before phase advancement. For Tasks, send the active change ID and fully expanded `docs/pegasus/changes/<change-id>/tasks.md` as separate routing data.
5. Before Apply, require exactly one approved task-slice identity and the current resolved delivery strategy. If forecast is over budget, High risk, recommends chaining, or requires a decision, ask the user to choose `stacked-to-main`, `feature-branch-chain`, or maintainer-approved `size:exception`. Historical preferences, defaults, inference, or tasks recommendations do not resolve strategy; `size:exception` also requires distinct maintainer approval. Unresolved strategy blocks Apply launch.
6. Dispatch exactly one matching specialist. If the agent tool or specialist is unavailable, launch fails, or no valid result returns, stop. Never transfer its ownership to the coordinator or another phase.

## Result Validation

Accept only observable launch evidence and the returned specialist envelope. Require the expected specialist identity, fresh-context delegation, canonical full artifact path when applicable, specialist ownership, truthful terminal operation states, risks/blockers, next action, and every field required by that specialist's result contract. Missing, partial, empty, duplicate, malformed, inconsistent, or unauthorized data blocks advancement.

For Design, require the complete canonical returned envelope, matching final/persistence revisions, exact `Post-persistence edits: none`, and terminal proposal-risk coverage state. Reproduce the valid envelope field-for-field with unchanged canonical labels and values, then ask exactly `¿Aprobás el diseño para avanzar a la fase de tareas?`. Do not reread Design or rerun its checks.

For Tasks, require exactly one canonical immutable v2 block, verify its SHA-256 and canonical JSON transport before decoding, validate the decoded full current-change tasks path, matching revisions, exact no-post-persistence-edit state, truthful persistence states, authorized strategy evidence, and no known duplicate handoff invocation. Copy a valid four-line block byte-for-byte; never reconstruct it. Invalid transport MUST block; do not ask strategy or launch apply. When its forecast requires a decision, ask exactly: `La previsión requiere definir la estrategia antes de apply. ¿Elegís \`stacked-to-main\`, \`feature-branch-chain\` o una excepción \`size:exception\` aprobada por el maintainer? No se iniciará apply hasta que respondas.`

Consume the Tasks forecast fields `Decision needed before apply`, `Chained PRs recommended`, `Chain strategy`, `400-line budget risk`, `Estimated authored changed lines`, `Estimated generated changed lines`, and `Tests included in estimate` only from the validated block.

For Apply and Verify, validate their existing versioned result envelopes without duplicating or weakening their phase contracts. Apply success authorizes only a distinct fresh Verify launch; Apply evidence never substitutes for Verify.

## Stable Boundaries

Artifacts remain change-scoped under `docs/pegasus/changes/<change-id>/`; root phase files are templates. Preserve useful progress/history by assigning merge behavior to the owning specialist. Artifact language defaults to English unless the user explicitly names another language for that artifact. Use one project-selected model without claiming hard per-phase routing or runtime parity.
