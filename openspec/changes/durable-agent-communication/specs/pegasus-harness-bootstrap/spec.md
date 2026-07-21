# Delta for Pegasus Harness Bootstrap

## ADDED Requirements

### Requirement: Compact Phase Transport

The harness MUST distinguish launch/result transport from durable workflow state. A launch MUST contain only the execution objective, current intent, stable identity, store mode, exact context handles, expected outputs, response focus/detail, exact resolved skills, and exceptional constraints. Generic policy MUST reside in specialist skills or focused lazy references; launches MUST NOT repeat it.

#### Scenario: Exact compact launch
- GIVEN a phase is authorized
- WHEN the orchestrator launches its specialist
- THEN it supplies the execution-specific fields and exact skills/context handles
- AND it omits generic recovery, persistence, and response-policy prose

#### Scenario: Path-root transcription is rejected
- GIVEN a required context handle contains a transcribed or non-canonical root/path
- WHEN the specialist validates the launch
- THEN it MUST block before phase work
- AND it MUST NOT infer a substitute handle

### Requirement: Disposable Semantic Responses

Every specialist response MUST contain `status`, `executive_summary`, `artifacts`, `durable_state_written`, `next_recommended`, and `risks`. `status` MUST use only `success`, `partial`, or `blocked`; `durable_state_written` MUST independently use only `complete`, `partial`, `not-written`, or `not-required`. Validation MUST be semantic and evidence-based, not presentation-exact. A response MUST NOT be used for continuation, duplicate detection, recovery, or durable authority.

#### Scenario: Status domains stay separate
- GIVEN execution succeeds but required closure persistence is incomplete
- WHEN the specialist responds
- THEN it reports truthful independent execution and persistence states
- AND the orchestrator MUST NOT infer advancement from `status` alone

#### Scenario: Status conflation is rejected
- GIVEN a response uses one status value to represent both execution and persistence
- WHEN response validation occurs
- THEN it MUST reject the response as semantically incomplete
- AND it MUST NOT infer durable closure from execution success

#### Scenario: Envelope continuation is rejected
- GIVEN a prior response envelope is available
- WHEN a later invocation needs continuity
- THEN it MUST use current durable artifacts and Pegasus Memory only
- AND it MUST NOT accept the envelope as recovery or duplicate evidence

### Requirement: Durable Authority and Reconciliation

`tasks.md` MUST be controlled-mutable authority for approved task state; checkbox changes MUST NOT alter task text, scope, ordering, or authorization. `apply-progress.md` MUST preserve cumulative execution history. `verify.md` MUST determine readiness, advancement, archive, and delivery eligibility. Pegasus Memory MUST index/summarize authoritative artifacts and MUST NOT override them. A visual TODO MAY coordinate a session but MUST NOT create or change durable state.

#### Scenario: Verify failure reconciles approved work
- GIVEN Verify finds an approved task incomplete
- WHEN the failure is reconciled
- THEN Apply history remains preserved and the original checkbox is reopened
- AND genuinely new remediation work requires separate approval and linked evidence

#### Scenario: Unauthorized replanning is rejected
- GIVEN an actor attempts to change task text while marking work complete or pending
- WHEN `tasks.md` is updated
- THEN the update MUST be blocked as unauthorized replanning
- AND only the permitted state change may proceed

### Requirement: Durable Evidence Identity and Integrity

Required material discoveries, fixes, decisions, restrictions, and blockers MUST be persisted immediately. Before closure, required progress, handoff, phase status, next action, summaries, and artifact references MUST be persisted. Records MUST use project → work scope → optional phase → optional slice identity; retry/session/attempt metadata MUST be append-only and non-key. Material observations MUST retain append-only lineage, semantic deduplication by identity plus evidence digest, and explicit `supersedes`, `resolves`, `related_to`, or `caused_by` relations.

Artifact references MUST use relative paths or durable topics and SHA-256 content revisions; Git metadata MAY be included only as traceability. Multi-file references MUST use a deterministic ordered path-and-digest manifest whose digest is recorded.

#### Scenario: Duplicate active observation is prevented
- GIVEN a retry reports identical material evidence for the same semantic identity
- WHEN persistence occurs
- THEN it deduplicates or merges the evidence without a second active conclusion
- AND a changed conclusion creates a linked superseding revision

#### Scenario: Stale revision is detected
- GIVEN a durable reference digest differs from current authoritative content
- WHEN it is used for recovery or routing
- THEN it MUST be treated as stale
- AND it MUST NOT authorize continuation until refreshed

### Requirement: Persistence Failure and Proportional Recovery

Pegasus Memory is a fundamental workflow dependency when persistence is required. A required persistence failure MUST preserve current artifacts, deliver any truthful partial result, report the blocker in `executive_summary` and `risks`, and block advancement until an explicit recovery persists under the same identity. The system MUST NOT silently retry indefinitely or create a Markdown fallback. The orchestrator MUST supply current intent and exact declared context needs; specialists MUST validate those handles and MUST NOT defensively read the full store or rely on prior envelopes.

#### Scenario: Immediate persistence failure blocks workflow
- GIVEN a material observation cannot be persisted
- WHEN the specialist returns
- THEN it returns `blocked` and `not-written` with the blocker surfaced
- AND result delivery MAY complete while workflow continuation remains prohibited

### Requirement: Vertical Contract Migration

The harness MUST migrate phase contracts vertically, beginning with PRD. Each phase slice MUST establish accepted durable artifact and Pegasus Memory evidence before deleting that phase's legacy result contract; it MUST NOT use adapters, translations, or dual authoritative contracts. Mixed-state compatibility between migration slices is NOT guaranteed. Only after all phases migrate MAY a terminal cleanup delete `shared/result-envelope.md`, remaining versioned result contracts, and obsolete common routing.

#### Scenario: Legacy contract deletion waits for durable evidence
- GIVEN a phase has not accepted its durable evidence
- WHEN its legacy result contract is considered for deletion
- THEN deletion MUST be blocked
- AND the phase MUST retain its current contract until the vertical slice is accepted
