# Verification Report: mcp-stdio-health-check — Slice 1

## Change

| Field | Value |
|---|---|
| Change ID | `mcp-stdio-health-check` |
| Slice | Slice 1 / Phase 1 Foundation-Packaging |
| Mode | Standard verification; strict TDD disabled |
| Artifact store | Hybrid: OpenSpec file + Engram memory |
| PR strategy | Chained PRs, `stacked-to-main` |
| Verdict | PASS |

## Completeness

| Item | Status | Evidence |
|---|---|---|
| 1.1 Resolver helpers | PASS | `pegasus_harness_bootstrap/cli.py` resolves PATH script first, then default local built script, then clone/install/build fallback, and preserves the exact unavailable warning. |
| 1.2 CLI plumbing | PASS | `--install-memory-mcp` appears in help and changes plan label from `default-on` to `explicit`; default-on memory planning runs without the flag. |
| 1.3 VS Code MCP template/package | PASS | `templates/harness/.vscode/mcp.json` exists with `command: "node"` and `{{MEMORY_MCP_SCRIPT_PATH}}`; `pyproject.toml` packages `templates/harness/.vscode/*.json`; smoke verifies generated absolute args. |
| Manifest operational-memory guard | PASS | `manifest.py` rejects active/last-change, memory, operational-memory, and recovery-state pointer keys; smoke verifies generated manifest exclusions. |
| Slice boundary | PASS | No README changes were present in the implementation diff. Phase 2 generated guidance health-gate work remains unchecked and not broadly implemented in this slice. |

## Build / Tests / Coverage Evidence

| Command | Result | Notes |
|---|---|---|
| `python3 -m compileall pegasus_harness_bootstrap` | PASS | Python package compiles. |
| `bash tests/smoke.sh` | PASS | Covers help output, default/explicit memory plan, generated `.vscode/mcp.json`, exact unavailable warning, no generated `docs/pegasus/memory`, and manifest exclusions. |
| `git diff --check` | PASS | No whitespace errors. |

## Spec Compliance Matrix

| Requirement / Scenario | Status | Runtime Evidence |
|---|---|---|
| MCP-first operational memory: configure memory by default and expose `--install-memory-mcp` | COMPLIANT for Slice 1 | `bash tests/smoke.sh` checks default-on plan and explicit flag help/plan output. |
| Resolve executable PATH → default local → clone/build fallback | COMPLIANT for Slice 1 | Source inspection confirms resolver order and clone/build helper. Smoke safely exercises unavailable path with `PEGASUS_MEMORY_MCP_SKIP_INSTALL=1`. |
| Generate VS Code stdio config with `node` and absolute built script path | COMPLIANT | `bash tests/smoke.sh` parses generated `.vscode/mcp.json` and asserts `command == "node"`, args equal the absolute built-script path, and the arg is absolute. |
| Missing install warns and attempts clone/build while default-on flow remains | COMPLIANT for Slice 1 | Source inspection confirms install attempt when not dry-run and not skipped; smoke confirms exact unavailable warning when install is skipped/unavailable. Network clone/build was not executed during verification. |
| Memory unavailable warning exact text | COMPLIANT | `bash tests/smoke.sh` asserts the exact warning in default run output and generated `AGENTS.md`. |
| Manifest-owned lifecycle metadata excludes operational memory/active-change pointers | COMPLIANT | Smoke inspects generated manifest; source guard rejects forbidden pointer keys recursively. |

## Correctness Review

| Area | Status | Evidence |
|---|---|---|
| Resolver behavior | PASS | `memory_mcp_path_script()`, `memory_mcp_default_script_path()`, `install_memory_mcp()`, and `resolve_memory_mcp()` implement the requested order and unavailable fallback. |
| Template rendering | PASS | `render_template()` replaces `{{MEMORY_MCP_SCRIPT_PATH}}`; generated JSON is not marker-wrapped, preserving valid JSON. |
| Packaging | PASS | `.vscode/*.json` is included in setuptools data files. |
| Uninstall behavior | PASS | Full-file JSON assets are removable via manifest ownership; smoke still passes uninstall scenarios. |
| MCP boundary | PASS | No generated `docs/pegasus/memory/` backend was reintroduced. |

## Design Coherence

| Decision | Status | Evidence |
|---|---|---|
| Default-on MCP setup plus explicit flag | PASS | Plan always includes memory setup; explicit flag labels it as explicit planning. |
| VS Code runtime config uses `node` plus absolute dist script | PASS | Template and smoke match the design contract. |
| Resolver remains in `cli.py` for reviewable scope | PASS | Helpers are focused and local to CLI. |
| Manifest does not become operational memory | PASS | Manifest contains install/ownership/update/uninstall/workspace metadata only, with forbidden-key guards. |
| Health-gated generated guidance deferred | PASS WITH SCOPE NOTE | Phase 2 tasks remain unchecked; this slice did not make broad guidance-health updates. Existing legacy/minimal guidance references predate this slice and are not expanded here. |

## Changed Files Reviewed

- `pegasus_harness_bootstrap/cli.py`
- `pegasus_harness_bootstrap/manifest.py`
- `templates/harness/.vscode/mcp.json`
- `pyproject.toml`
- `tests/smoke.sh`
- `openspec/changes/mcp-stdio-health-check/tasks.md`
- `openspec/changes/mcp-stdio-health-check/apply-progress.md`

## Issues

### CRITICAL

None.

### WARNING

None.

### SUGGESTION

- Future Slice 2 should add true health-gated generated guidance and distinct `not_found`, `ambiguous`, `read_error`, and `persistence_error` handling evidence. Current Slice 1 intentionally verifies only resolver/config/packaging foundation.

## Final Verdict

PASS — Slice 1 matches the approved Foundation-Packaging scope, runtime smoke evidence passed, and no blockers were found.
