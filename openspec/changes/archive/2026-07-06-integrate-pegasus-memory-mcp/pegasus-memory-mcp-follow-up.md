# External Follow-up: pegasus-memory-mcp API gaps

This note records follow-up work for the separate `pegasus-memory-mcp` project. It is not part of the `pegasus-ia-bootstrap` implementation and does not modify `/home/serg/ia-scripts/pegasus-memory-mcp`.

## Bootstrap boundary

Pegasus Bootstrap consumes the MCP tool contract only. Generated harness guidance may reference MCP recovery, search, status, and write outcomes, but bootstrap must not depend on MCP implementation details, database schema, source modules, or local repository files.

## API gaps to address externally

| Gap | Why it matters for Pegasus | Desired external capability |
|---|---|---|
| `projectKey` / `projectId` mismatch | Recovery guidance can identify a project by key, while write/status operations may require a stable project id. Generated guidance needs a contract-level way to continue from recovered context without exposing lookup mechanics to users. | Return or resolve the stable write identifier as part of active-context recovery, or provide a documented project resolution tool. |
| Health / ping | Current bootstrap guidance treats failed recovery/search as memory unavailable. A dedicated health check would make startup diagnostics and user-facing unavailable behavior cleaner. | Add a lightweight `health`/`ping` MCP tool that reports availability without requiring a memory query side effect. |
| Active-context ambiguity support | Pegasus must not ask users to choose internal memory records when active context is ambiguous. | Provide a safe non-user-facing disambiguation result, deterministic current-context selection, or a contract-level ambiguity status with recommended next action. |

## Expected handling until resolved

- Continue using file artifacts under `docs/pegasus/changes/<change-id>/` as the source of truth for PRD, proposal, spec, design, tasks, apply-progress, and verification.
- Use MCP memory for summaries, active context, task status, handoffs, observations, and artifact references when available.
- If MCP cannot provide a safe active context, continue from file artifacts and record this external follow-up rather than exposing internal ambiguity to the user.
