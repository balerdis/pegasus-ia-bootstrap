# PEGASUS_APPLY_RESULT_V1

## Scope And Authority

This manually loaded result reference owns the Apply v1 result schema. It does not own generic envelope truthfulness or Apply workflow.

Return these canonical fields in this order:

1. `status`: `blocked`, `in_progress`, or `completed`.
2. `specialist`: `sdd-apply`.
3. `authorized_slice`: exact slice identity and source.
4. `delivery_strategy`: resolved strategy and current authorization evidence, or the unmet gate.
5. `duplicate_check`: sources checked and result.
6. `changed_files`: exact paths changed by this run, or `none`.
7. `preliminary_checks`: commands and exact results, or `not run: <reason>`.
8. `progress_updates`: task/apply-progress/optional verify updates, or `none`.
9. `persistence`: health, recovery, and write outcomes, or truthful unavailable/not-needed states.
10. `skill_resolution`: exact path outcomes, `no-match`, and fallback status.
11. `blockers_risks`: blockers and residual risks, or `none`.
12. `next_action`: distinct fresh-context `sdd-verify`, next approved slice, or exact unblock action.

For `blocked`, identify the first unmet gate and do not imply implementation, checks, progress updates, persistence, or completion occurred when they did not.
