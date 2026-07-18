# PEGASUS_DESIGN_RESULT_V1

## Scope And Authority

This manually loaded result reference owns only the Design v1 phase-specific fields, canonical labels, and schema. It does not own generic envelope truthfulness, status meaning, persistence behavior, Design workflow, or orchestrator validation.

Return these canonical fields once with unchanged labels and truthful values. Narrative prose does not satisfy the final-response contract.

```text
Artifact language: <selected language|not selected — blocking gap>
Explicit language override evidence: <exact user instruction/reference|None — English default enforced|not applicable — blocking gap>
Language gate: <passed|blocked: exact unresolved issues|not run — design artifact was not written>
Marker validation: <passed|blocked: exact marker issues|not run: reason>
Traceability validation: <passed|blocked: exact per-entry traceability issues|not run: reason>
Proposal risk coverage validation: <passed|blocked: exact missing risk/design/test coverage|not run: reason>
Deferred technical choices: <structured summary of every choice and next gate|None / Ninguna|not evaluated: reason>
Initial recovery result: <not_found|ambiguous|recovered|read_error|unavailable|other truthful result>
Recovery/ensure transitions: <ordered transitions after initial recovery, or None>
Final artifact revision: <content hash|explicit stable revision token|not written>
Persistence artifact revision: <same identity recorded by persistence|not applicable>
Post-persistence edits: <none|detected: exact mutation|not applicable>
```

```text
Pegasus Memory persistence summary:
ensure_project: <succeeded|not needed|failed: reason>
ensure_change: <succeeded|not needed|failed: reason>
record_artifact: <succeeded|not needed|failed: reason>
record_observation: <succeeded|not needed|failed: reason>
record_task_progress: <succeeded|not needed|failed: reason>
record_handoff: <succeeded|not needed|failed: reason>
```

Then return:

```text
Status: <completed|blocked>
Specialist agent: sdd-design
Fresh-context delegation: confirmed by orchestrator invocation
Artifact path: <path|not written>
Artifact writer/validator/persistence owner: sdd-design
Risks/blockers: <concise summary|None>
Next action: <review/approval|user answer|repair language gate|other exact action>
```

This is the existing Design wire envelope named `PEGASUS_DESIGN_RESULT_V1`; do not rename, reorder semantically, omit, summarize, reconstruct, or dilute any label/value. For completed output, require every validation passed, identical final/persistence revisions, exact `Post-persistence edits: none`, all six terminal persistence states, and `Next action: review/approval`. For blocked output, identify the first unmet gate and never imply writing, validation, persistence, approval, or completion that did not occur.
