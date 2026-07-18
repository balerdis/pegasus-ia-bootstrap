# PEGASUS_PRD_RESULT_V1

## Scope And Authority

This manually loaded result reference owns only the PRD v1 phase-specific fields and schema. It does not own generic envelope truthfulness, status meaning, persistence behavior, or PRD workflow.

Return these canonical fields in this order:

1. `status`: `blocked`, `in_progress`, or `completed`.
2. `specialist`: `doc-designer`.
3. `request_and_artifact`: exact product-request identity and PRD path.
4. `discovery_outcome`: product areas captured and material ambiguities, or `not started: <reason>`.
5. `artifact_validation`: readback, structure, language, and approval-indicator results, or `not run: <reason>`.
6. `approval_state`: in-file owner/date/status/checkbox agreement and truthful readiness for human review.
7. `persistence`: required PRD operation outcomes and file-only classification when applicable.
8. `skill_resolution`: exact path outcomes, `no-match`, and fallback status.
9. `blockers_risks`: blockers and residual product risks, or `none`.
10. `next_action`: exact unblock action or human PRD review/explicit in-file approval.

For `blocked`, identify the first unmet gate and do not imply discovery, edits, validation, persistence, approval, or completion occurred when they did not.
