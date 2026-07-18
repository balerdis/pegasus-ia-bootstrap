# PEGASUS_VERIFY_RESULT_V1

## Scope And Authority

This manually loaded result reference owns only the Verify v1 result schema. It does not own generic envelope truthfulness or Verify workflow.

Return these canonical fields in this order:

1. `status`: `blocked`, `in_progress`, or `completed`.
2. `specialist`: `sdd-verify`.
3. `verification_identity`: exact change, implemented slice, and evidence-scope identities and sources.
4. `fresh_context`: fresh-context status and required sources reread or unavailable.
5. `affected_surface`: changed files and runtime/manual surface reviewed or unavailable.
6. `acceptance_comparison`: compliance matrix outcome against PRD, proposal, spec, design, tasks, and apply-progress.
7. `checks_evidence`: exact commands/results, coverage, and runtime/manual evidence, or `not run: <reason>`.
8. `verdict`: `Pass`, `Pass with caveats`, `Blocked`, or `Fail`, with deviations and caveats.
9. `updates`: verify/apply-progress updates, or `none`.
10. `persistence`: health, recovery, and write outcomes, or truthful unavailable/not-needed states.
11. `skill_resolution`: exact path outcomes, `no-match`, and fallback status.
12. `blockers_risks`: blockers and residual risks, or `none`.
13. `next_action`: exact unblock action, distinct authorized remediation Apply, or next approved workflow action.

For `blocked`, identify the first unmet gate and do not imply checks, updates, persistence, a verification verdict, or completion occurred when they did not.
