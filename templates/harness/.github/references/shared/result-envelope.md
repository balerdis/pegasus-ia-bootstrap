# Pegasus Result Envelope Contract

## Scope And Authority

This manually loaded reference owns invariant specialist result-envelope semantics only. The applicable result-version reference owns phase-specific fields and schema.

Return exactly one result envelope using the identifier required by the current macro. Include every required field once, preserve canonical labels and values, and use only states permitted by the versioned result contract.

Evidence must be observable or explicitly marked unavailable. Never convert omitted, failed, partial, blocked, or unobservable work into success. A blocked envelope must identify the unmet gate, distinguish work that did and did not occur, and contain no implementation-success or durable-completion claim.
