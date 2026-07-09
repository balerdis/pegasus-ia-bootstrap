# SDD Result Contract

## status
complete

## executive_summary
One coordinated cross-repo change is the right shape: add a no-side-effect `health/ping` tool in `pegasus-memory-mcp`, then update Pegasus Bootstrap templates/docs so VS Code can launch the server via workspace MCP stdio config and the orchestrator checks availability before the first recovery/save. The current bootstrap already enforces the exact unavailable-memory warning; the missing pieces are the health probe and the VS Code MCP workspace config surface.

## artifacts
- `pegasus-memory-mcp/src/adapters/mcp/index.ts` — add `health/ping` tool, handler, and server registration.
- `pegasus-memory-mcp/src/index.ts` — export the new MCP surface if needed by tests/imports.
- `pegasus-memory-mcp/tests/mcp/mcp-adapter.test.ts` — extend tool-surface and no-side-effect coverage.
- `pegasus-memory-mcp/package.json` — likely no script changes, but verification is here.
- `pegasus-ia-bootstrap/openspec/specs/pegasus-harness-bootstrap/spec.md` — add MCP availability-check and VS Code stdio auto-launch requirements.
- `pegasus-ia-bootstrap/templates/harness/.github/{copilot-instructions.md,agents/pegasus-orchestrator.agent.md,instructions/pegasus-memory.instructions.md,agents/memory-maintainer.agent.md,prompts/memory-update.prompt.md}` — add startup/before-first-save health probe guidance.
- `pegasus-ia-bootstrap/templates/harness/.vscode/*` — new workspace MCP config surface is likely needed (for `mcp.json` and possibly `settings.json`).
- `pegasus-ia-bootstrap/README.md` and `tests/smoke.sh` — document and verify the new workspace config/output.
- `pegasus-ia-bootstrap/pyproject.toml` — package the new template files.

## next_recommended
Proceed as one SDD change with two linked implementation slices: ship `pegasus-memory-mcp` first (health tool), then land Bootstrap template/spec updates that consume it. Verify with `npm run test:mcp && npm run build && npm run typecheck` in `pegasus-memory-mcp`, and `bash tests/smoke.sh` in `pegasus-ia-bootstrap`.

## risks
- VS Code MCP auto-start is configuration-sensitive; workspace `mcp.json` plus `chat.mcp.autoStart` must be aligned with the current VS Code MCP contract.
- A health probe only proves server availability, not project context correctness; recovery can still fail or be ambiguous afterward.
- `projectKey`/`projectId` mismatch remains a separate contract gap and may still need follow-up.

## skill_resolution
Loaded `sdd-explore` and `cognitive-doc-design`; both were satisfied by read-only exploration. No implementation changes were made.
