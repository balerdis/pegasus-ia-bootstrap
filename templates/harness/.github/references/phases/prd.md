# PRD Phase Contract

## Scope And Authority

This manually loaded phase reference owns only the detailed `doc-designer` PRD discovery and documentation workflow. It is subordinate to the current macro and authoritative over shared references for PRD-specific behavior. It does not approve the PRD or authorize Proposal.

## Execution Brief And Sources

Validate the compact execution brief against `.pegasus-bootstrap-ia/manifest.json` `workspace.project_name` and the authorized root or change-scoped PRD. Every root PRD lifecycle launch requires exact `<project_key>:prd:root`; aliases are mismatches. Validate every context artifact by relative path and SHA-256 under the manifest-established workspace root. Missing, absolute, transcribed-root, stale, ambiguous, contradictory, or mismatched handles block with no edit or write; never infer a substitute or reconstruct a root.

Use the authorized product request and current PRD as default product sources. The root PRD is the intentional natural-entry canonical template before a change exists; active change work uses `docs/pegasus/changes/<change-id>/prd.md`. Do not inspect unrelated changes unless the request or direct user instruction explicitly identifies a dependency. Do not silently decide product scope.

## Material-Gap Gate

Before any artifact edit, Memory health/recovery, or persistence, evaluate whether unresolved inputs can materially change scope, target users, user-visible behavior/defaults, business rules, content policy, constraints, success criteria, or approval readiness. Assumptions do not resolve those decisions.

When material gaps exist, ask one concise grouped round of product questions and return `blocked` awaiting input. This path performs zero artifact edits, zero `ensure_project` or `ensure_change`, zero artifact, observation, handoff, or task-progress records, and zero approval request or advancement. Load `.github/references/shared/semantic-response.md` only to return the truthful blocked response: report the questions, `artifact_edit: not run`, and every persistence operation as `not needed: awaiting product input`. A later answer authorizes drafting only through a fresh launch that re-establishes identity, duplicate state, authorization, and material completeness. When authoritative inputs genuinely resolve every material decision, do not invent questions and proceed.

## Discovery Content

Document the user/business problem, affected users and situations, current gap, desired user-visible outcomes, scope and out-of-scope boundaries, non-goals, product/business rules and tradeoffs, edge cases, constraints, measurable success criteria, ambiguities/open questions, and approval owner/date/status. Preserve distinctions between evidence, user decisions, assumptions, and unresolved questions.

Keep the PRD product-facing. Do not add technical design, architecture, data models, requirements matrices, acceptance scenarios, implementation steps, tasks, PR splitting, delivery strategy, or review-budget decisions. Do not implement code or begin Proposal.

## Artifact And Approval

Preserve existing Pegasus ownership markers and useful history. For a new change-scoped PRD, use the canonical managed PRD template and exact current-change path. Select artifact language under the shared language contract; preserve standard orthography and translate human-readable structure consistently for an explicit override.

After writing, reread the complete artifact and validate its identity, structure, product coverage, open questions, success criteria, language consistency, and approval indicators. Approval readiness means the PRD is coherent enough for human review; it is not approval. Proposal remains blocked until the artifact status says `Approved`, every present approval checkbox is checked, and all approval indicators agree.

## Durable Drafting And Return

Only after the material-gap gate passes, load `.github/references/shared/persistence.md`, `.github/references/shared/durable-state.md`, and `.github/references/shared/semantic-response.md` before their respective work. Call Pegasus Memory `health` before recovery. Recover only current artifact and Memory evidence under the exact stable identity; never read a prior response envelope.

After `health` succeeds, satisfy project/change preconditions using exact brief `project_key`. Call `ensure_project` only for that key. For a new change, call `ensure_change` before change-scoped writes using that `project_id` and authorized `change_id`; NEVER call `ensure_change` for root PRD. Add only supported flat optional fields when needed, use `kind` as the sole classification alias, and never send `type`, nested metadata, decisions, questions, or artifact summaries through `ensure_change`.

Persist material PRD/product discoveries, decisions, restrictions, and blockers as event-time observations using the durable-state dedupe and append-only lineage rules. A failed required event write preserves files but returns `blocked`/`not-written`; truthful partial delivery is allowed while advancement is prohibited.

After creation or refinement, reread the artifact, compute its relative-path SHA-256 reference, then perform closure-time artifact index, summary, phase status, next action, and handoff writes. Record every outcome truthfully. Any failed required closure write makes durable state partial or not-written and blocks advancement until explicit same-identity recovery. Tell the user the relative path, revision, ambiguities, approval state, and next action through the semantic response.
