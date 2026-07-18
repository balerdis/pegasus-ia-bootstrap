# PEGASUS_SPEC_RESULT_V1

## Scope And Authority

This manually loaded result reference owns only the Spec v1 phase-specific fields and schema. It does not own generic envelope truthfulness, status meaning, persistence behavior, or Spec workflow.

Return these canonical fields in this order:

1. `status`: `blocked`, `in_progress`, or `completed`.
2. `specialist`: `sdd-spec`.
3. `input_gates`: exact PRD and proposal paths plus observed in-file approval indicators.
4. `artifact`: exact Spec path and whether it was created, refined, or unchanged.
5. `requirements_and_scenarios`: normative requirement count, scenario coverage, edge/failure coverage, non-goals, and exact source traceability.
6. `material_gaps`: resolved and unresolved gaps, evidence, owners, impacts, next steps, and needed-by gates, or `none`.
7. `artifact_validation`: full-reread, exact marker, language, terminology, traceability, scenario, and phase-boundary results, or `not run: <reason>`.
8. `persistence`: exact six-operation summary and file-only/partial classification when applicable.
9. `skill_resolution`: exact path outcomes, `no-match`, and fallback status.
10. `blockers_risks`: blockers and residual Spec risks, or `none`.
11. `next_action`: exact unblock action or human Spec review/approval before Design.

For `blocked`, identify the first unmet gate and do not imply Spec writing, validation, persistence, approval, or completion occurred when it did not.
