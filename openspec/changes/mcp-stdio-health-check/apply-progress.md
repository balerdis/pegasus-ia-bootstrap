# Apply Progress: MCP Stdio Health Check

## Status

- Mode: Standard (strict TDD disabled; Bash smoke verification available)
- Delivery: chained PR slice, `stacked-to-main`
- Current slice: Slice 2 / Harness Guidance, Docs, and Smoke Coverage
- Previous apply-progress: merged from Slice 1 OpenSpec and Engram history

## Completed Tasks

- [x] 1.1 Add resolver helpers in `pegasus_harness_bootstrap/cli.py` for PATH → default local → clone/build fallback and the exact unavailable warning.
- [x] 1.2 Add CLI plumbing for default-on memory setup and explicit `--install-memory-mcp` planning without changing manifest ownership fields.
- [x] 1.3 Package `templates/harness/.vscode/*.json` in `pyproject.toml` and add `templates/harness/.vscode/mcp.json` with `node` plus absolute built-script args.
- [x] 2.1 Update `templates/harness/.github/copilot-instructions.md` to require MCP `health` before first recovery/save and preserve `not_found`, `ambiguous`, `read_error`, and `persistence_error`.
- [x] 2.2 Update `templates/harness/.github/agents/pegasus-orchestrator.agent.md` and `templates/harness/.github/agents/memory-maintainer.agent.md` to gate saves on `health` and use the exact unavailable warning.
- [x] 2.3 Align `templates/harness/.github/instructions/pegasus-memory.instructions.md` and `templates/harness/.github/prompts/memory-update.prompt.md` with the no-Markdown-fallback contract.
- [x] 3.1 Wire the new MCP path token through bootstrap rendering so generated workspaces receive absolute `mcp.json` paths.
- [x] 3.2 Keep `.pegasus-bootstrap-ia/manifest.json` install/ownership-only and add assertions for excluded operational memory fields.
- [x] 3.3 Update `README.md` with the default-on install flow, local fallback behavior, and the `npm rebuild better-sqlite3` gotcha.
- [x] 4.1 Extend `tests/smoke.sh` to check help output, `--install-memory-mcp`, and generated `.vscode/mcp.json` shape.
- [x] 4.2 Add smoke coverage for warning text, `health`-gated recovery/save guidance, and no Markdown memory fallback.
- [x] 4.3 Verify rollback path in smoke notes: slice 2 can revert without removing slice 1 resolver/packaging work.

## Implementation Notes

- Slice 1 added default-on Pegasus Memory MCP planning in the bootstrap plan output; `--install-memory-mcp` makes the same workspace stdio setup explicit without changing manifest ownership fields.
- Slice 1 resolver order is PATH script, default local script, then clone/build fallback into `/home/serg/ia-scripts/pegasus-memory-mcp` from `stable/0.1.0`.
- Slice 1 smoke tests set `PEGASUS_MEMORY_MCP_SKIP_INSTALL=1` and `PEGASUS_MEMORY_MCP_ROOT` to avoid network/build side effects while exercising the unavailable path safely.
- `.vscode/mcp.json` is rendered as valid JSON without ownership comments; manifest/uninstall handling keeps full-file JSON assets manifest-owned and removable.
- Manifest guardrails reject operational-memory and recovery-state pointer keys in addition to active/last-change pointers.
- Slice 2 guidance now requires MCP `health` before first recovery or save in Copilot instructions, orchestrator, memory maintainer, memory instruction, and memory update prompt surfaces.
- Slice 2 guidance preserves the distinct MCP consumer states: `not_found`, `ambiguous`, `read_error`, and `persistence_error` are not collapsed into unavailability.
- README now documents the default-on memory MCP flow, PATH/default/clone resolution order, exact unavailable warning, default DB path, and `npm rebuild better-sqlite3` gotcha.
- Smoke coverage now statically verifies generated health-gated guidance, no Markdown memory fallback, warning preservation, generated `.vscode/mcp.json`, and manifest exclusions.

## Files Changed

| File | Action | What Was Done |
|---|---|---|
| `pegasus_harness_bootstrap/cli.py` | Modified in Slice 1 | Added memory MCP resolver/install helpers, default-on/explicit plan output, template token rendering, and unavailable warning output. |
| `pegasus_harness_bootstrap/manifest.py` | Modified in Slice 1 | Kept JSON templates valid and extended forbidden operational pointer guards. |
| `templates/harness/.vscode/mcp.json` | Created in Slice 1 | Added VS Code MCP stdio config using `node` and the rendered absolute built script path. |
| `pyproject.toml` | Modified in Slice 1 | Packaged `templates/harness/.vscode/*.json`. |
| `templates/harness/.github/copilot-instructions.md` | Modified in Slice 2 | Requires `health` before first recovery/save and preserves distinct MCP consumer states. |
| `templates/harness/.github/agents/pegasus-orchestrator.agent.md` | Modified in Slice 2 | Adds startup `health` gate, save gate, exact warning, and state distinction guidance. |
| `templates/harness/.github/agents/memory-maintainer.agent.md` | Modified in Slice 2 | Gates recovery/save through `health` and preserves unavailable/recoverable/error state boundaries. |
| `templates/harness/.github/instructions/pegasus-memory.instructions.md` | Modified in Slice 2 | Centralizes MCP `health`, no-Markdown-fallback, and state distinction guidance. |
| `templates/harness/.github/prompts/memory-update.prompt.md` | Modified in Slice 2 | Aligns manual memory update workflow with health-gated MCP saves and no Markdown fallback. |
| `README.md` | Modified in Slice 2 | Documents default-on MCP setup, fallback behavior, exact warning, default DB path, and native dependency rebuild gotcha. |
| `tests/smoke.sh` | Modified in Slices 1 and 2 | Adds smoke assertions for MCP config, warning text, health-gated generated guidance, no Markdown fallback, and manifest exclusions. |
| `openspec/changes/mcp-stdio-health-check/tasks.md` | Modified in Slices 1 and 2 | Marks all implementation tasks complete for the chained PR boundary. |
| `openspec/changes/mcp-stdio-health-check/apply-progress.md` | Modified in Slices 1 and 2 | Merges Slice 1 and Slice 2 implementation progress. |

## Verification

| Command | Result |
|---|---|
| `python3 -m compileall pegasus_harness_bootstrap` | Passed |
| `bash tests/smoke.sh` | Passed |
| `git diff --check` | Passed |

## Rollback Notes

- Slice 2 rollback is isolated to generated guidance, README, smoke assertions, and SDD progress/task checkboxes.
- Reverting Slice 2 does not remove Slice 1 resolver helpers, package data wiring, manifest guards, or `.vscode/mcp.json` rendering.
- Slice 1 remains the dependency base for the stacked-to-main chain; Slice 2 can be reverted independently if guidance/docs need revision.

## Deviations

None — implementation matches the Slice 2 design boundary. VS Code UI auto-start remains out of repo-level verification and is covered by static `.vscode/mcp.json` shape plus generated guidance smoke assertions.

## Remaining Tasks

None.

## Workload / PR Boundary

- Mode: chained PR slice
- Chain strategy: stacked-to-main
- Current work unit: Slice 2 / Harness Guidance, Docs, and Smoke Coverage
- Boundary: starts from Slice 1 commit `41ae78d` on `main`; ends with health-gated generated guidance, README documentation, smoke assertions, and merged SDD progress only.
- Review budget impact: current Slice 2 implementation is about 101 tracked line changes plus SDD apply-progress update; within the 400-line Slice 2 budget.
