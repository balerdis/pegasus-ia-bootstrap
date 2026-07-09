# Proposal: MCP Stdio Health Check

## Intent

Consume the completed `pegasus-memory-mcp` availability contract so Pegasus Bootstrap installs/configures persistent memory by default, verifies availability through `health`, and falls back honestly when memory is unavailable.

## Traceability

- Readiness handoff: `PEGASUS_MEMORY_MCP_READY_FOR_BOOTSTRAP.md` (`pegasus-memory-mcp` stable `0.1.0`, commit `5b2aee8`).
- Exploration: `openspec/changes/mcp-stdio-health-check/explore.md`.
- External MCP implementation is complete; this change only consumes that contract from Bootstrap.

## Users and Situations

- Pegasus users bootstrapping a new VS Code/Copilot workspace who expect memory to work by default.
- Returning agents/orchestrators that must know whether MCP memory is safe before recovery/save.
- New machines where `pegasus-memory-mcp` may be absent, missing from PATH, or not built.

## Scope

### In Scope
- Default-on memory MCP install/config flow with `--install-memory-mcp` as the explicit flag surface.
- Resolve MCP from PATH first, then default local install path; if missing, warn and attempt GitHub clone/install/build.
- Generate/configure VS Code stdio MCP runtime using `node` plus absolute built-script args.
- Use `health` before first memory recovery/save and distinguish unavailable, empty, ambiguous, read, and persistence states.
- Preserve exact unavailable warning: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`.

### Out of Scope
- Changes inside `pegasus-memory-mcp`.
- `docs/pegasus/memory/` as a backend or migration path.
- Making the manifest operational memory.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `pegasus-harness-bootstrap`: add default memory MCP install/config, VS Code stdio health probing, and unavailable-memory fallback behavior.

## Approach

Update Bootstrap CLI/templates/guidance so file artifacts remain source of truth and MCP stores operational memory/status/summaries. The installer configures memory by default, recovers from common missing-install cases, and reports health failures without blocking file-only SDD work.

## Assumptions and Decision Gaps

- Default local install path follows the handoff path convention unless specs choose a stricter path.
- Decision gap for spec: exact opt-out flag name and failure wording for clone/build errors beyond the approved unavailable warning.

## Affected Areas

| Area | Impact |
|---|---|
| `openspec/specs/pegasus-harness-bootstrap/spec.md` | Modified requirements |
| `pegasus_harness_bootstrap/` | Modified install/config behavior |
| `templates/harness/.vscode/` | New/modified MCP config |
| `templates/harness/.github/` | Modified orchestrator guidance |
| `README.md`, `tests/smoke.sh` | Modified docs/verification |

## Risks

| Risk | Likelihood | Mitigation |
|---|---|---|
| Network/build failure | Medium | Warn, report cause, continue file-only when appropriate. |
| VS Code MCP config drift | Medium | Tie spec to stdio command/args contract. |

## Rollback Plan

Revert Bootstrap/template/spec changes for MCP install/config and health probing.

## Acceptance Handoff to Spec

- Spec must define default-on install/config, PATH/default-path lookup, clone/build fallback, health-gated recovery/save, exact unavailable warning, and no Markdown memory fallback.
