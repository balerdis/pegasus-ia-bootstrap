# Pegasus Persistence Contract

## Scope And Authority

This manually loaded reference owns generic Pegasus Memory recovery and persistence behavior. It does not own phase workflow, status meaning, or result schemas. Follow `.github/instructions/pegasus-memory.instructions.md` for the complete workspace memory policy.

Call Pegasus Memory MCP `health` before recovery or persistence. After health succeeds, recover project/change context and relevant task progress. Satisfy documented project/change preconditions before writes. Keep `not_found`, `ambiguous`, `read_error`, `persistence_error`, and foreign-key failures distinct from unavailability.

Merge durable observations, task progress, artifact references, blockers, evidence, and handoff state into useful history; never replace it wholesale. Report every required or attempted persistence operation truthfully.

Any durable mutation to a previously recorded artifact invalidates its persisted summary and state. After complete artifact readback, merge/refresh the artifact record and observation under the same exact project/change identity, preserving useful history rather than overwriting it. Edit size and file-only scope do not make persistence unnecessary. `not needed` is valid only when no durable mutation occurred (for example awaiting-input or read-only work) or when the operation is explicitly non-applicable.

If MCP is unavailable, show exactly: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`. Continue file work only when otherwise authorized, do not claim persistence succeeded, and do not write a Markdown memory fallback. For migrated phases, follow `durable-state.md`: required failures block advancement even when truthful partial result delivery is possible.
