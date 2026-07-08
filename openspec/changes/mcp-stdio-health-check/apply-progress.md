# Apply Progress: MCP Stdio Health Check

## Status

- Mode: Standard (strict TDD disabled; Bash smoke verification available)
- Delivery: chained PR slice, `stacked-to-main`
- Current slice: Slice 1 / Phase 1 Foundation-Packaging
- Previous apply-progress: none found

## Completed Tasks

- [x] 1.1 Add resolver helpers in `pegasus_harness_bootstrap/cli.py` for PATH → default local → clone/build fallback and the exact unavailable warning.
- [x] 1.2 Add CLI plumbing for default-on memory setup and explicit `--install-memory-mcp` planning without changing manifest ownership fields.
- [x] 1.3 Package `templates/harness/.vscode/*.json` in `pyproject.toml` and add `templates/harness/.vscode/mcp.json` with `node` plus absolute built-script args.

## Implementation Notes

- Added default-on Pegasus Memory MCP planning in the bootstrap plan output; `--install-memory-mcp` makes the same workspace stdio setup explicit without changing manifest ownership fields.
- Resolver order is PATH script, default local script, then clone/build fallback into `/home/serg/ia-scripts/pegasus-memory-mcp` from `stable/0.1.0`.
- Smoke tests set `PEGASUS_MEMORY_MCP_SKIP_INSTALL=1` and `PEGASUS_MEMORY_MCP_ROOT` to avoid network/build side effects while exercising the unavailable path safely.
- `.vscode/mcp.json` is rendered as valid JSON without ownership comments; manifest/uninstall handling was adjusted so full-file JSON assets remain manifest-owned and removable.
- Manifest guardrails were extended to reject operational-memory and recovery-state pointer keys in addition to active/last-change pointers.

## Files Changed

| File | Action | What Was Done |
|---|---|---|
| `pegasus_harness_bootstrap/cli.py` | Modified | Added memory MCP resolver/install helpers, default-on/explicit plan output, template token rendering, and unavailable warning output. |
| `pegasus_harness_bootstrap/manifest.py` | Modified | Kept JSON templates valid and extended forbidden operational pointer guards. |
| `templates/harness/.vscode/mcp.json` | Created | Added VS Code MCP stdio config using `node` and the rendered absolute built script path. |
| `pyproject.toml` | Modified | Packaged `templates/harness/.vscode/*.json`. |
| `tests/smoke.sh` | Modified | Added Slice 1 smoke coverage for help output, memory setup planning, generated MCP config shape, package inclusion, warning output, and manifest exclusions. |
| `openspec/changes/mcp-stdio-health-check/tasks.md` | Modified | Marked Phase 1 tasks complete and recorded the resolved `stacked-to-main` chain strategy. |

## Verification

| Command | Result |
|---|---|
| `python3 -m compileall pegasus_harness_bootstrap` | Passed |
| `bash tests/smoke.sh` | Passed |
| `git diff --check` | Passed |

## Deviations

None — implementation matches the Slice 1 design boundary. Phase 2 health-gated generated guidance and Phase 3 README documentation remain intentionally out of scope.

## Remaining Tasks

- [ ] 2.1 Update `templates/harness/.github/copilot-instructions.md` to require MCP `health` before first recovery/save and preserve `not_found`, `ambiguous`, `read_error`, and `persistence_error`.
- [ ] 2.2 Update `templates/harness/.github/agents/pegasus-orchestrator.agent.md` and `templates/harness/.github/agents/memory-maintainer.agent.md` to gate saves on `health` and use the exact unavailable warning.
- [ ] 2.3 Align `templates/harness/.github/instructions/pegasus-memory.instructions.md` and `templates/harness/.github/prompts/memory-update.prompt.md` with the no-Markdown-fallback contract.
- [ ] 3.1 Wire the new MCP path token through bootstrap rendering so generated workspaces receive absolute `mcp.json` paths.
- [ ] 3.2 Keep `.pegasus-bootstrap-ia/manifest.json` install/ownership-only and add assertions for excluded operational memory fields.
- [ ] 3.3 Update `README.md` with the default-on install flow, local fallback behavior, and the `npm rebuild better-sqlite3` gotcha.
- [ ] 4.1 Extend `tests/smoke.sh` to check help output, `--install-memory-mcp`, and generated `.vscode/mcp.json` shape.
- [ ] 4.2 Add smoke coverage for warning text, `health`-gated recovery/save guidance, and no Markdown memory fallback.
- [ ] 4.3 Verify rollback path in smoke notes: slice 2 can revert without removing slice 1 resolver/packaging work.

## Workload / PR Boundary

- Mode: chained PR slice
- Chain strategy: stacked-to-main
- Current work unit: Slice 1 / Phase 1 Foundation-Packaging
- Boundary: starts from approved SDD artifacts plus readiness handoff; ends with resolver/default-on workspace MCP stdio packaging and smoke coverage only.
- Review budget impact: about 155 tracked line changes plus one new 10-line template and SDD progress updates; within the 400-line Slice 1 budget.
