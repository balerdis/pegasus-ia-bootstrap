# Proposal: Adapt Bootstrap to VS Code/Copilot

## Intent

Move Pegasus IA bootstrap from Cursor-first output to VS Code/Copilot-first output for Copilot Max in VS Code. The harness defines the workflow for users who already use VS Code/Copilot, while Cursor remains legacy-compatible.

## Scope

### In Scope
- Generate `.github/copilot-instructions.md`, `.github/instructions/`, `.github/prompts/`, and `.github/agents/`.
- Keep `AGENTS.md` and Cursor legacy compatibility.
- Add a visible Pegasus orchestrator agent using official Copilot subagent coordination.
- Map SDD phases and selected OpenCode-inspired agents, excluding `review-risk` and `review-readability`.
- Define opt-in global/user VS Code/Copilot install with backups, dry-run, and path strategy.
- Update README, smoke tests, baseline spec, and completion output.

### Out of Scope
- Domain app code, GitHub remote setup, CI, deploy, or scaffolding.
- Removing Cursor legacy support in this change.
- Onboarding users from zero to VS Code/Copilot.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `pegasus-harness-bootstrap`: change the contract to VS Code/Copilot-first while retaining `AGENTS.md`, local memory, SDD templates, safe global install, and Cursor legacy compatibility.

## Approach

Use the local-first CLI/template model, replacing default Cursor-facing artifacts with Copilot `.github/` instructions, prompts, and agents. The Pegasus orchestrator uses `tools: ['agent']`, restricted `agents: [...]`, hidden subagents where useful, and handoffs for SDD flow. Global configuration stays opt-in with dry-run and timestamped backups.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `bin/pegasus-harness-bootstrap` | Modified | flags, paths, output, global behavior |
| `templates/harness/` | Modified | Copilot `.github/`, `AGENTS.md`, docs |
| `templates/cursor-global/` | Modified | legacy or replacement global strategy |
| `README.md`, `tests/smoke.sh` | Modified | usage and verification |
| `openspec/specs/pegasus-harness-bootstrap/spec.md` | Modified | baseline requirements |

## Proposal Question Round

Assumption for review: Judgment Day agents may be mapped now if low-risk, or deferred if the first slice becomes too large.

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Global Copilot path convention is not 1:1 with Cursor | Med | opt-in, dry-run, backups, documented assumptions |
| OpenCode agents may not map perfectly | Med | define supported behavior; defer ambiguous agents |
| Legacy Cursor compatibility increases surface area | Med | smoke-test both primary and legacy paths |

## Rollback Plan

Revert this proposal and later implementation commits; generated workspaces are local files and global changes are recoverable through timestamped backups.

## Dependencies

- Official VS Code/Copilot instructions, prompts, custom agents, and handoffs.

## Success Criteria

- [ ] Default harness is VS Code/Copilot-first and includes `AGENTS.md`.
- [ ] Optional global install is explicit, dry-runnable, and backed up.
- [ ] Cursor compatibility remains available as legacy.
- [ ] Smoke tests cover generated Copilot assets, legacy compatibility, and no app/Git/CI/deploy output.
