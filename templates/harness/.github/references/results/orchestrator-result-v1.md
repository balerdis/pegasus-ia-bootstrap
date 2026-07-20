# Pegasus Orchestrator Result V1

## Scope And Authority

This manually loaded reference owns only the coordinator result schema. It does not authorize execution or define specialist result fields.

Return exactly one envelope:

```text
PEGASUS_ORCHESTRATOR_RESULT_V1
Status: routed|blocked|awaiting-approval|awaiting-strategy|completed-boundary
Requested phase: <phase|undetermined>
Launch identity: <project:prd:root|change:phase[:slice]|not established>
Specialist agent: <agent|not launched>
Fresh-context delegation: <observable evidence|not launched|unavailable>
Authorization: <approved|blocked: reason|not applicable>
Duplicate launch gate: <passed: exact state and evidence|blocked: reason|not established>
Strategy gate: <resolved: strategy|blocked: unresolved|not applicable>
Specialist result validation: <passed|blocked: reason|not returned>
Delegated work claimed: <observable work only|none>
Coordinator fallback work: none
Risks/blockers: <value|none>
Next action: <single boundary action>
```

`routed` requires established canonical project identity, exact launch identity, passed duplicate state/evidence, and one observable matching launch. Alias/mismatched identity, mutation-inconsistent persistence, or unavailable/invalid/missing specialist result is `blocked`, with `Coordinator fallback work: none`. A valid PRD awaiting-input result is surfaced as `blocked` with its questions and no Proposal authorization. Every continuation and block returns exactly this one envelope; prose-only output is invalid. Never claim specialist completion without its valid envelope.
