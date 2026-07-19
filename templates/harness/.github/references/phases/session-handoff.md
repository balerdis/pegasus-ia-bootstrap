# Session Handoff Phase Contract

## Scope And Authority

This manually loaded phase reference owns only the detailed `session-handoff` workflow. It is subordinate to the current macro and authoritative over shared references for Handoff-specific behavior. It does not authorize later work or Memory Maintenance outside the handoff record.

## Current-State Sources

Treat the supplied current live-session snapshot as authority for conversational goal, constraints, completed work, incidents, and intent. Verify current repository and artifact facts directly where permitted. Current code/tests and current change artifacts outrank historical Pegasus Memory records; useful history supplies continuity but never replaces newer live state. Repo-clean is not session-clean.

Follow `.github/instructions/pegasus-sdd-boundaries.instructions.md` and `.github/instructions/pegasus-memory.instructions.md`: handoff output defaults to English unless the user explicitly names another language for that artifact. Chat, persona, source, and prior artifact language do not imply an override. Preserve immutable identifiers and the localized unavailable warning exactly.

Call Pegasus Memory `health` before recovery. When healthy, recover relevant task progress, decisions, artifact status, verification evidence, and prior handoffs. For a change-scoped handoff, read the exact current `docs/pegasus/changes/<change-id>/verify.md`; root phase files are canonical templates only. Keep unverified historical claims labelled as historical or unknown.

## Handoff Content And History

Create a concise handoff/session summary containing current state, completed work, open risks, blockers, verification status, important files, critical project/change/task/branch/commit/PR identifiers when applicable, restrictions, and exactly one next action. Distinguish verified, live-session, historical, and unavailable evidence. Never fabricate completion, verification, synchronization, or persistence.

Merge the new handoff into existing useful history instead of replacing prior decisions, progress, evidence, blockers, incidents, or handoffs. Correct stale operational facts explicitly while preserving relevant history. Never erase conflicting history silently; record the resolution or unresolved contradiction.

Satisfy project/change write preconditions before `record_handoff`. If recovery returns `not_found` with `project_not_found`, call `ensure_project`; call `ensure_change` before a change-scoped handoff when the change is missing. Use minimal documented ensure inputs. Persist exactly one handoff for this phase and report the operation truthfully.

If `pegasus-memory-mcp` is unavailable or `health` fails, show exactly: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`. Do not write Markdown memory, do not claim persistence, and return a blocked result because this phase's handoff persistence did not occur. `not_found`, `ambiguous`, `read_error`, `persistence_error`, and foreign-key failures are not unavailability; report their exact state and block when safe current-state selection or persistence cannot complete.

## Stop Boundary

After the handoff record and result are complete, stop. Do not resume implementation, start the next action, modify project/change artifacts, run verification, or perform unrelated memory maintenance.
