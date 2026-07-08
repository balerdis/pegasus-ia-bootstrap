# Tasks: MCP Stdio Health Check

## Review Workload Forecast

| Field | Value |
|---|---|
| Estimated changed lines | 450-650 |
| 400-line budget risk | High |
| Chained PRs recommended | Yes |
| Suggested split | PR 1: resolver + `.vscode/mcp.json` packaging + manifest guard; PR 2: harness guidance + smoke/docs |
| Delivery strategy | chained PRs selected |
| Chain strategy | stacked-to-main |

Decision needed before apply: No
Chained PRs recommended: Yes
Chain strategy: stacked-to-main
400-line budget risk: High

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | Resolve/install memory MCP and render VS Code stdio config | PR 1 | Base: tracker branch; verify PATH → default local → clone/build fallback and packaged `.vscode/mcp.json` |
| 2 | Gate memory use on `health` and preserve exact unavailable behavior | PR 2 | Base: PR 1; verify guidance, warnings, and no Markdown fallback |

## Phase 1: Foundation / Packaging

- [x] 1.1 Add resolver helpers in `pegasus_harness_bootstrap/cli.py` for PATH → default local → clone/build fallback and the exact unavailable warning.
- [x] 1.2 Add CLI plumbing for default-on memory setup and explicit `--install-memory-mcp` planning without changing manifest ownership fields.
- [x] 1.3 Package `templates/harness/.vscode/*.json` in `pyproject.toml` and add `templates/harness/.vscode/mcp.json` with `node` plus absolute built-script args.

## Phase 2: Harness Guidance / Contract

- [x] 2.1 Update `templates/harness/.github/copilot-instructions.md` to require MCP `health` before first recovery/save and preserve `not_found`, `ambiguous`, `read_error`, and `persistence_error`.
- [x] 2.2 Update `templates/harness/.github/agents/pegasus-orchestrator.agent.md` and `templates/harness/.github/agents/memory-maintainer.agent.md` to gate saves on `health` and use the exact unavailable warning.
- [x] 2.3 Align `templates/harness/.github/instructions/pegasus-memory.instructions.md` and `templates/harness/.github/prompts/memory-update.prompt.md` with the no-Markdown-fallback contract.

## Phase 3: Wiring / Documentation

- [x] 3.1 Wire the new MCP path token through bootstrap rendering so generated workspaces receive absolute `mcp.json` paths.
- [x] 3.2 Keep `.pegasus-bootstrap-ia/manifest.json` install/ownership-only and add assertions for excluded operational memory fields.
- [x] 3.3 Update `README.md` with the default-on install flow, local fallback behavior, and the `npm rebuild better-sqlite3` gotcha.

## Phase 4: Testing / Verification

- [x] 4.1 Extend `tests/smoke.sh` to check help output, `--install-memory-mcp`, and generated `.vscode/mcp.json` shape.
- [x] 4.2 Add smoke coverage for warning text, `health`-gated recovery/save guidance, and no Markdown memory fallback.
- [x] 4.3 Verify rollback path in smoke notes: slice 2 can revert without removing slice 1 resolver/packaging work.
