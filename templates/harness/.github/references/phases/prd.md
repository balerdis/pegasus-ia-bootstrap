# PRD Phase Contract

## Scope And Authority

This manually loaded phase reference owns only the detailed `doc-designer` PRD discovery and documentation workflow. It is subordinate to the current macro and authoritative over shared references for PRD-specific behavior. It does not approve the PRD or authorize Proposal.

## Input And Source Rules

Use the authorized product request and current PRD as default product sources. The root PRD is the intentional natural-entry canonical template before a change exists; active change work uses `docs/pegasus/changes/<change-id>/prd.md`. Do not inspect unrelated changes unless the request or direct user instruction explicitly identifies a dependency. Do not silently decide product scope.

Call Pegasus Memory `health` before recovery. When healthy, recover relevant project/change context. If product or business decisions remain open, ask one concise round of key questions before editing or finalizing. A missing answer that can change scope, user-visible behavior, business rules, success, or approval readiness is a material gap; keep it visible with owner and needed-by gate or stop when it blocks a coherent PRD.

## Discovery Content

Document the user/business problem, affected users and situations, current gap, desired user-visible outcomes, scope and out-of-scope boundaries, non-goals, product/business rules and tradeoffs, edge cases, constraints, measurable success criteria, ambiguities/open questions, and approval owner/date/status. Preserve distinctions between evidence, user decisions, assumptions, and unresolved questions.

Keep the PRD product-facing. Do not add technical design, architecture, data models, requirements matrices, acceptance scenarios, implementation steps, tasks, PR splitting, delivery strategy, or review-budget decisions. Do not implement code or begin Proposal.

## Artifact And Approval

Preserve existing Pegasus ownership markers and useful history. For a new change-scoped PRD, use the canonical managed PRD template and exact current-change path. Select artifact language under the shared language contract; preserve standard orthography and translate human-readable structure consistently for an explicit override.

After writing, reread the complete artifact and validate its identity, structure, product coverage, open questions, success criteria, language consistency, and approval indicators. Approval readiness means the PRD is coherent enough for human review; it is not approval. Proposal remains blocked until the artifact status says `Approved`, every present approval checkbox is checked, and all approval indicators agree.

## Persistence And Return

After `health` succeeds, satisfy project/change preconditions. For a new change, call `ensure_change` before change-scoped writes using `project_id` and `change_id` by default; add only supported flat optional fields when needed, use `kind` as the sole classification alias, and never send `type`, nested metadata, decisions, questions, or artifact summaries through `ensure_change`.

After readback validation, merge PRD/product discoveries, decisions, open questions, approval status, and artifact references into Pegasus Memory through `record_observation` and `record_artifact`; do not replace useful history. Report `ensure_project`, `ensure_change`, `record_artifact`, and `record_observation` as `succeeded`, `not needed`, or `failed: <reason>`. If required artifact or observation persistence fails, report the PRD as file-only with the reason. Tell the user the exact PRD path, summarize material ambiguities and approval state, and request review/explicit approval without advancing the workflow.
