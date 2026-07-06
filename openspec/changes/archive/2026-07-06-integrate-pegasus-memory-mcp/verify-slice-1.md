## Verification Report

**Change**: `integrate-pegasus-memory-mcp`
**Slice**: Slice 1 — Guidance Contract
**Mode**: Standard
**Verdict**: PASS WITH WARNINGS

### Completeness

| Metric | Value |
|--------|-------|
| Slice 1 tasks total | 3 |
| Slice 1 tasks complete | 3 |
| Slice 1 tasks incomplete | 0 |
| Later-slice tasks incomplete | Expected; Phase 2, Phase 3, and Phase 4 remain open |

### Build & Tests Execution

| Command | Result | Evidence |
|---|---|---|
| `git diff --check` | ✅ Passed | No whitespace errors reported. |
| `bash tests/smoke.sh` | ✅ Passed | `Smoke tests passed.` |
| `npx @fission-ai/openspec validate --all` | ✅ Passed | `change/integrate-pegasus-memory-mcp` and `spec/pegasus-harness-bootstrap` passed; totals: 2 passed, 0 failed. |

### Spec Compliance Matrix

| Requirement / Scenario | Result | Evidence |
|---|---|---|
| MCP-first operational memory — memory available | ✅ COMPLIANT | Changed guidance recovers/searches/saves through `pegasus-memory-mcp` in `AGENTS.md`, `.github/copilot-instructions.md`, `.github/instructions/pegasus-memory.instructions.md`, orchestrator, SDD agents, and phase prompts. |
| Durable records are produced | ✅ COMPLIANT | Guidance requires durable decisions, observations, handoffs, artifact references, and task progress to be saved through MCP when available. |
| MCP contract only | ⚠️ PARTIAL, REMEDIATED BY CLEANUP | Original verification found that several files used negative guardrails that named MCP implementation-detail categories. The corrective cleanup replaces those references with a public MCP tool-contract statement. |
| Memory unavailable behavior | ✅ COMPLIANT | The exact warning appears in the touched guidance where persistence can be attempted: `El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente`. Guidance also blocks persistent-save claims and Markdown fallback. |
| Work continues without memory saves | ✅ COMPLIANT | Guidance allows artifact work to continue while persistent memory saves are unavailable. |
| Active-context recovery stays non-user-facing | ✅ COMPLIANT | Orchestrator and SDD prompt guidance say not to ask the user to resolve MCP recovery details when active-context recovery is ambiguous. |
| Change-cycle artifacts remain file-based | ✅ COMPLIANT | Guidance keeps PRD/proposal/spec/design/tasks/apply-progress/verify under `docs/pegasus/` or change-scoped paths, while MCP stores summaries/status/references. |
| No Markdown-memory migration required / no fallback | ✅ COMPLIANT for Slice 1 touched files | Touched memory behavior states `docs/pegasus/memory/` is deprecated or says not to fall back to Markdown memory. Untouched template/docs leftovers are documented as Phase 2/3 work. |

### Correctness (Static Evidence)

| Check | Status | Notes |
|---|---|---|
| Slice scope | ✅ Pass | CBM/diff show only generated guidance/instruction/agent/prompt files changed, plus OpenSpec change artifacts. No CLI/package implementation or `pegasus-memory-mcp` repo changes were made for Slice 1. |
| MCP-first guidance | ✅ Pass | Updated guidance consistently says recover/search/save through MCP when available. |
| Deprecated Markdown memory | ✅ Pass with expected leftovers | Slice 1 touched files avoid Markdown fallback; remaining `docs/pegasus/memory/` templates, memory-maintainer, memory-update prompt, Cursor rules, and smoke expectations remain documented future slices. |
| Exact unavailable warning | ✅ Pass | Found 12 matches in touched guidance/prompt/agent files. |
| No user-facing active-context ambiguity prompt | ✅ Pass | Guidance says to continue from artifacts and record external MCP follow-up instead of asking the user to resolve MCP recovery details. |
| No MCP implementation-detail coupling | ⚠️ Warning, remediated by cleanup | Original wording was close to the boundary; corrective cleanup now uses public MCP tool-contract wording. |

### Design Coherence

| Decision | Followed? | Notes |
|---|---|---|
| Use MCP tool contract only | ⚠️ Mostly, remediated by cleanup | Behavior follows the boundary; corrective cleanup now avoids naming MCP implementation details in generated guidance. |
| Deprecate Markdown memory | ✅ Yes for Slice 1 | Removal of generated memory templates remains Phase 2. |
| Warn exactly and disable memory saves when MCP unavailable | ✅ Yes | Exact Spanish warning is present where appropriate. |
| Keep active-context ambiguity non-user-facing | ✅ Yes | Guidance explicitly avoids asking users to resolve MCP recovery details. |
| Keep SDD artifacts file-based | ✅ Yes | Artifact source-of-truth remains `docs/pegasus/` / change-scoped docs. |

### Issues Found

**CRITICAL**: None.

**WARNING**:
- Remediated by corrective cleanup: touched generated guidance now uses public MCP tool-contract wording and avoids naming MCP implementation-detail examples.
- `tests/smoke.sh` still expects generated `docs/pegasus/memory/*` and does not assert the new MCP-first warning yet. This is acceptable for Slice 1 because Phase 4 owns smoke expectation updates, but runtime coverage for the new guidance contract is still partial.
- Untracked `PRD-bootstrap-cli-lifecycle.md` exists in the working tree and is outside this Slice 1 scope. It was not reviewed as part of this verification.

**SUGGESTION**:
- Keep the generated guidance phrasing focused on MCP tool inputs, outputs, and documented capabilities; do not reintroduce MCP implementation-detail examples.

### Files Reviewed

- `openspec/changes/integrate-pegasus-memory-mcp/prd.md`
- `openspec/changes/integrate-pegasus-memory-mcp/proposal.md`
- `openspec/changes/integrate-pegasus-memory-mcp/specs/pegasus-harness-bootstrap/spec.md`
- `openspec/changes/integrate-pegasus-memory-mcp/design.md`
- `openspec/changes/integrate-pegasus-memory-mcp/tasks.md`
- `openspec/changes/integrate-pegasus-memory-mcp/apply-progress.md`
- Current git diff and changed guidance files under `templates/harness/**`
- `tests/smoke.sh`

### Safe to Proceed

Yes — safe to proceed to Slice 2 with remaining planned-scope warnings. The Slice 1 guidance contract is implemented and the MCP implementation-detail wording warning was remediated by corrective cleanup. The next slice should keep the planned scope while removing/repurposing deprecated Markdown memory outputs.

### Skill Resolution

`paths-injected` — loaded `sdd-verify` and `cognitive-doc-design` from the exact requested skill paths; also read the shared SDD phase common protocol and verify report format.
