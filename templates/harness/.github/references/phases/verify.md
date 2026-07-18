# SDD Verify Phase Contract

## Scope And Authority

This manually loaded phase reference owns only the detailed `sdd-verify` workflow. It is subordinate to the current macro, authoritative over shared references for Verify-specific behavior, and does not authorize change, slice, or evidence identities.

## Inputs And Fresh Reads

Require the exact current-change paths `docs/pegasus/changes/<change-id>/prd.md`, `docs/pegasus/changes/<change-id>/proposal.md`, `docs/pegasus/changes/<change-id>/spec.md`, `docs/pegasus/changes/<change-id>/design.md`, `docs/pegasus/changes/<change-id>/tasks.md`, `docs/pegasus/changes/<change-id>/apply-progress.md`, and existing or creatable `docs/pegasus/changes/<change-id>/verify.md`, plus the authorized changed-file/evidence surface. Treat fresh context as an operational rule, not a runtime guarantee. Before judging, freshly read `.github/copilot-instructions.md`, `.github/instructions/pegasus-sdd-boundaries.instructions.md`, every required current-change artifact, existing verification history, changed implementation files, and relevant recovered MCP task progress when memory is available. Explain any unavailable surface; block when its absence prevents a truthful verdict.

## Verification Workflow

Derive the affected surface from the authorized slice, apply-progress, changed files, and acceptance sources. Compare implementation against PRD, proposal, spec requirements/scenarios, design constraints, tasks, and apply-progress rather than treating passing tests as sufficient.

Run focused and broader commands appropriate to the affected surface. Capture exact commands, exit/results, test coverage, and runtime or manual evidence. Do not invent unavailable evidence. Record a compliance matrix, changed files reviewed, commands/results, coverage/manual checks, deviations, unresolved questions, risks, and one explicit slice verdict: `Pass`, `Pass with caveats`, `Blocked`, or `Fail`.

## Updates And Status

Merge the verification entry into `docs/pegasus/changes/<change-id>/verify.md`; preserve prior commands, failures, deviations, risks, and caveats, marking superseded evidence instead of deleting it. Update apply-progress verification status and next action without rewriting implementation history. When memory is healthy, persist verification evidence, deviations, verdict, remediation needs, artifact status, truthful task progress, and handoff notes according to the shared persistence contract.

Use `completed` only after the authorized verification and required updates finish, including a `Pass`, `Pass with caveats`, or evidence-backed `Fail` verdict. Use `blocked` when an unmet gate prevents a verdict. `Fail` is a completed verification outcome, not permission to remediate.

## Stop And Return

Do not make unrelated changes or edit implementation unless the user separately authorizes a later remediation run. Never invoke Apply. Stop after recording the verdict and caveats. For `Blocked` or `Fail`, leave exact remediation evidence and return control so the user or orchestrator can authorize a distinct Apply run; otherwise return the next approved workflow action.
