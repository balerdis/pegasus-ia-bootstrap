# Design: MCP Stdio Health Check

## Technical Approach

Extend the existing Python bootstrap and generated Copilot harness guidance so memory is configured by default, health-gated before use, and still optional for file-only SDD work when unavailable. The bootstrap remains local-first: it writes workspace files from `templates/harness/`, records only install/ownership metadata in `.pegasus-bootstrap-ia/manifest.json`, and never stores operational memory in the manifest or Markdown fallback files.

## Architecture Decisions

| Decision | Choice | Alternatives considered | Rationale |
|---|---|---|---|
| MCP setup surface | Add default-on memory setup plus explicit `--install-memory-mcp`; no opt-out in this change. | Keep memory guidance-only; require manual install. | The approved spec says default bootstrap flow configures memory and exposes the flag explicitly. |
| Runtime config | Generate `templates/harness/.vscode/mcp.json` with `command: "node"` and `args: [absolute dist/bin/pegasus-memory-mcp.js]`. | Use a shell command or package manager shim. | VS Code stdio config is clearer and matches the ready handoff contract. |
| Resolver | Create focused helpers in `pegasus_harness_bootstrap/cli.py` to resolve PATH first, then `/home/serg/ia-scripts/pegasus-memory-mcp/dist/bin/pegasus-memory-mcp.js`, then clone/install/build. | Move to a new package module immediately. | Current CLI centralizes install planning/writes; helper functions keep the change reviewable without a broader refactor. |
| Health boundary | Generated agents call MCP `health` before first recovery/save; bootstrap smoke tests statically verify config/guidance. | Require VS Code UI auto-start proof in tests. | VS Code MCP auto-launch is UI/runtime-specific; static config plus optional process smoke is the reliable repo-level boundary. |
| Manifest scope | Leave `manifest.py` schema as install/ownership/update/uninstall only and extend smoke assertions if needed. | Add memory installation state to manifest. | Spec forbids operational memory and active/last change pointers in the manifest. |

## Data / Control Flow

```text
CLI setup
  ├─ parse args (`--install-memory-mcp` visible, default-on behavior)
  ├─ resolve memory MCP: PATH → default local dist script → clone/npm ci/build
  ├─ render `.vscode/mcp.json` with absolute script path
  ├─ write harness templates + manifest
  └─ print warning and continue file-only if MCP cannot be prepared

Generated harness session
  ├─ read Copilot/orchestrator instructions
  ├─ call MCP `health`
  ├─ if unavailable: show exact Spanish warning, no persistent-memory claims
  └─ if healthy: recovery may return `not_found`, `ambiguous`, `read_error`, or `persistence_error` distinctly
```

## File Changes

| File | Action | Description |
|---|---|---|
| `pegasus_harness_bootstrap/cli.py` | Modify | Add memory MCP constants, resolver/install/build helpers, plan output, template rendering token for MCP script path, and default-on setup flow. |
| `templates/harness/.vscode/mcp.json` | Create | Workspace MCP stdio config using `node` and the resolved absolute built script path. |
| `templates/harness/.github/copilot-instructions.md` | Modify | Require `health` before first recovery/save and state consumer-state distinctions. |
| `templates/harness/.github/agents/pegasus-orchestrator.agent.md` | Modify | Add startup health gate and unavailable/recoverable/error state handling. |
| `templates/harness/.github/instructions/pegasus-memory.instructions.md` | Modify | Centralize MCP health and state contract. |
| `templates/harness/.github/agents/memory-maintainer.agent.md` | Modify | Gate saves through `health`; preserve exact warning. |
| `templates/harness/.github/prompts/memory-update.prompt.md` | Modify | Align manual memory update workflow with health-gated saves. |
| `pyproject.toml` | Modify | Package `templates/harness/.vscode/*.json`. |
| `tests/smoke.sh` | Modify | Assert help flag, generated `.vscode/mcp.json`, absolute script path rendering, warning preservation, no Markdown memory fallback, and manifest exclusions. |
| `README.md` | Modify | Document default memory MCP setup, local install fallback, npm rebuild gotcha, and verification boundaries. |

## Interfaces / Contracts

```python
Memory MCP resolver result:
  script_path: Path          # absolute dist/bin/pegasus-memory-mcp.js
  source: "path" | "default-local" | "installed" | "unavailable"
  warning: str | None        # exact unavailable warning when source is unavailable
```

Generated `mcp.json` contract:

```json
{"servers":{"pegasus-memory-mcp":{"command":"node","args":["/absolute/path/dist/bin/pegasus-memory-mcp.js"]}}}
```

## Testing Strategy

| Layer | What to Test | Approach |
|---|---|---|
| Unit | Resolver/path rendering helpers | Prefer small Python-level checks if test structure is added; otherwise cover through smoke. |
| Smoke | CLI help, dry-run plan, generated `.vscode/mcp.json`, packaged template inclusion, manifest exclusions, warning text | Extend `tests/smoke.sh`. |
| Static guidance | Health-before-recovery/save and distinct states | `assert_file_contains` over generated harness files. |
| VS Code runtime | Auto-start behavior | Document as out of repo-level verification; only config shape is verified here. |

## Migration / Rollout

No data migration required. Rollback is reverting CLI/template/docs/test changes. Review slicing is recommended: slice 1 for resolver/config packaging, slice 2 for guidance/docs/smoke assertions if the implementation exceeds the 400-line review budget.

## Risks / Open Questions

- PATH binaries may be package-manager shims; implementation must resolve or fall back to an absolute built script path safely.
- Clone/build uses network and native SQLite dependencies; failures must warn and continue file-only without claiming persistence.
- No blocking open questions.
