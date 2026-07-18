# PEGASUS_PROPOSAL_RESULT_V1

## Scope And Authority

This manually loaded result reference owns only the Proposal v1 phase-specific fields and schema. It does not own generic envelope truthfulness, status meaning, persistence behavior, or Proposal workflow.

Return these canonical fields in this order:

1. `status`: `blocked`, `in_progress`, or `completed`.
2. `specialist`: `sdd-proposal`.
3. `prd_gate`: exact PRD path and observed in-file approval indicators.
4. `artifact`: exact proposal path and whether it was created, refined, or unchanged.
5. `traceability_and_gaps`: PRD traceability plus resolved/unresolved material gaps and needed-by gates.
6. `artifact_validation`: exact marker, readback, and language results, or `not run: <reason>`.
7. `persistence`: exact six-operation summary and file-only/partial classification when applicable.
8. `skill_resolution`: exact path outcomes, `no-match`, and fallback status.
9. `blockers_risks`: blockers and residual proposal risks, or `none`.
10. `next_action`: exact unblock action or human proposal review/approval before Spec.

For `blocked`, identify the first unmet gate and do not imply proposal writing, validation, persistence, approval, or completion occurred when it did not.
