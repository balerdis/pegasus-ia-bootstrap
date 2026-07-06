# Design: Integrate Pegasus Memory MCP

## Technical Approach

Make generated Pegasus guidance MCP-first while keeping the bootstrap lightweight: update templates and smoke expectations, not add a Pegasus runtime client. The integration boundary is a documented “Pegasus Memory Port” in generated instructions: agents call `pegasus-memory-mcp` tools for recovery, search, and writes; file artifacts under `docs/pegasus/` remain the SDD source of truth.

## Architecture Decisions

| Decision | Choice | Alternatives considered | Rationale |
|---|---|---|---|
| Memory boundary | Use MCP tool contract only | Import MCP source, read SQLite, or add Python client | Preserves decoupling and keeps bootstrap as template generation. |
| Markdown memory | Deprecate and stop generating `docs/pegasus/memory/*` | Keep fallback/co-source or guided migration | User approved no Markdown backend; existing bootstrap has no real migration need. |
| Unavailable MCP | Warn exactly and disable memory saves | Silent fallback or hard-stop all work | Project/change files can still progress, but persistence claims must stay honest. |
| Active-context ambiguity | Internal degraded handling | Ask user to choose MCP records | Avoids exposing memory internals; missing MCP support becomes external follow-up. |

## Data / Control Flow

```text
Session start
  -> generated orchestrator calls get_active_context(projectKey)
  -> selected: use returned change/context + read docs/pegasus artifacts
  -> not_found/ambiguous/error: continue from file artifacts, record MCP follow-up when possible

Phase work
  -> update docs/pegasus/changes/<change-id>/... artifact
  -> record_artifact + record_task_progress + record_decision/observation/handoff as applicable

MCP unavailable
  -> show exact warning
  -> allow artifact edits
  -> block record_* calls and any claim that persistent memory was saved
```

## MCP Tools Used

| Tool | Purpose |
|---|---|
| `get_active_context` / `recover_context` | Initial project/change recovery. |
| `search_memory` | Find prior decisions, learnings, task progress, and handoffs. |
| `list_recent_changes` / `list_recent_events` | Lightweight continuity and duplicate-work checks. |
| `record_artifact` | Link PRD/proposal/spec/design/tasks/apply/verify artifact path, status, and summary. |
| `record_task_progress` | Replace `tasks-log.md` for slice status and blockers. |
| `record_decision`, `record_observation`, `record_handoff` | Persist durable decisions, discoveries, and session handoffs. |

No health tool exists in the current public API; generated guidance should detect availability by attempting an MCP recovery/search call and treating missing tool, startup failure, validation failure caused by unavailable server, or transport error as unavailable.

## File Changes

| File / Area | Action | Impact |
|---|---|---|
| `bin/pegasus-harness-bootstrap` | Modify | Exclude removed memory templates from generated inventory if needed; keep template-copy machinery simple. |
| `templates/harness/docs/pegasus/memory/*` | Delete | Deprecated operational memory templates. |
| `templates/harness/AGENTS.md`, `.github/copilot-instructions.md` | Modify | Replace Markdown-memory startup/write rules with MCP-first recovery, unavailable warning, and artifact reads. |
| `.github/agents/*`, `.github/prompts/*`, `.github/instructions/*` | Modify | Replace `docs/pegasus/memory` reads/writes with MCP tool usage and blocked-save behavior. Rename or repurpose `memory-maintainer` / `memory-update` for MCP memory. |
| `templates/harness/docs/pegasus/{proposal,design,tasks,apply-progress,verify}.md` | Modify | Remove Markdown memory references; keep artifact-source-of-truth guidance. |
| `.cursor/rules/pegasus-memory.mdc` | Modify | Legacy guidance must also point to MCP-first memory without Markdown fallback. |
| `tests/smoke.sh` | Modify | Expected files and assertions remove memory templates and assert MCP-first text + exact warning. |
| `openspec/specs/pegasus-harness-bootstrap/spec.md` | Modify at archive | Merge delta after implementation/verify. |

## Artifact Interaction

`docs/pegasus/changes/<change-id>/` artifacts are authoritative phase documents. MCP records store summaries, artifact paths, active context, decisions, handoffs, and task status. If MCP is down, only file artifacts update; later sessions may recover from files but no retrospective Markdown memory is written.

## Testing Strategy

| Layer | What to Test | Approach |
|---|---|---|
| Smoke | Generated tree excludes `docs/pegasus/memory/*` and contains MCP-first guidance | Update `tests/smoke.sh` expected files/assertions. |
| Smoke | Exact unavailable warning appears in generated orchestrator/instructions | `assert_file_contains` with exact Spanish string. |
| Regression | No banned Markdown-memory references remain | Add recursive grep failure for `docs/pegasus/memory` in generated target, allowing only historical/deprecation wording if deliberately needed. |
| CLI | Dry-run/completion stay local-first | Existing smoke coverage continues; no MCP server startup in bootstrap. |

## Migration / Rollout / Rollback

No data migration required. Roll out by updating templates and smoke tests. Roll back by reverting template/test changes; no MCP or filesystem data conversion is involved.

## Risks / Open Questions

- Current MCP write tools use `projectId` while recovery uses `projectKey`; generated guidance may need a reliable way to obtain `projectId` after recovery. External follow-up may be needed in `pegasus-memory-mcp`.
- MCP lacks an explicit health tool; a `health`/`ping` tool could make unavailable detection cleaner.
- Ambiguous active-context responses currently include candidates; Pegasus guidance must not ask the user to resolve those internals.
