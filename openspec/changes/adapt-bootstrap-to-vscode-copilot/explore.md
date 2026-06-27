# Exploration: Adapt Pegasus IA bootstrap to VS Code/Copilot-first

## Current State

The current bootstrap is Cursor-first. It generates a local harness with `AGENTS.md`, `.cursor/rules/`, `docs/pegasus/`, and `docs/pegasus/memory/`, plus an opt-in global Cursor rule path behind `--install-cursor-global`.

Official VS Code / GitHub Copilot docs support a different file model:

- Repository instructions: `.github/copilot-instructions.md`
- Scoped instructions: `.github/instructions/*.instructions.md`
- Prompt files: `.github/prompts/*.prompt.md`
- Custom agents: `.github/agents/*.agent.md`
- Agent frontmatter can define `name`, `description`, `tools`, `handoffs`, and subagent usage via `agent` / `runSubagent`
- Workspace instructions can also be controlled with `chat.instructionsFilesLocations`

Source URLs:

- https://code.visualstudio.com/docs/copilot/customization/custom-agents
- https://code.visualstudio.com/docs/copilot/guides/customize-copilot-guide
- https://code.visualstudio.com/docs/copilot/guides/context-engineering-guide
- https://code.visualstudio.com/docs/copilot/customization/custom-instructions
- https://docs.github.com/en/copilot/concepts/prompting/response-customization
- https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-copilot-overview

The current repo baseline to adapt is:

- `bin/pegasus-harness-bootstrap` — CLI behavior, target layout, global install flag, completion text
- `templates/harness/AGENTS.md` — workspace guidance currently mentions Cursor
- `templates/harness/.cursor/rules/*` — Cursor-specific workflow and memory rules
- `templates/cursor-global/pegasus-global.mdc` — global Cursor guidance
- `templates/harness/docs/pegasus/*` — SDD and memory templates
- `README.md` and `tests/smoke.sh` — user-facing docs and smoke verification
- `openspec/config.yaml` and `openspec/specs/pegasus-harness-bootstrap/spec.md` — still describe Cursor-first output

## Affected Areas

- `bin/pegasus-harness-bootstrap` — replace Cursor-centric output, paths, and completion guidance with VS Code/Copilot-first equivalents.
- `templates/harness/AGENTS.md` — rewrite start-here guidance for VS Code/Copilot, agent mode, and local memory.
- `templates/harness/.cursor/rules/*` — likely replace with `.github/instructions/`, `.github/prompts/`, and `.github/agents/` assets.
- `templates/cursor-global/*` — likely remove or replace with a Copilot-oriented global/user-level strategy if one is still desired.
- `templates/harness/docs/pegasus/*` — keep the SDD/memory concept, but update references from Cursor to VS Code/Copilot.
- `README.md` — update usage, target layout, and verification docs.
- `tests/smoke.sh` — rename assertions for new file paths, new flags, and new completion text.
- `openspec/config.yaml` / `openspec/specs/pegasus-harness-bootstrap/spec.md` — re-state the bootstrap as VS Code/Copilot-first.

## Approaches

1. **Full VS Code/Copilot migration** — generate `.github/` instructions, prompts, and agents as the primary bootstrap output; keep the Pegasus SDD/memory layer, but remove Cursor-specific artifacts from the default harness.
   - Pros: matches the new target directly; minimal conceptual mismatch; aligns with official docs.
   - Cons: requires the biggest rename/layout change; may need a decision on whether any user-global Copilot equivalent is worth supporting.
   - Effort: Medium

2. **Compatibility bridge** — generate VS Code/Copilot assets first, but retain a small Cursor compatibility layer for a transition period.
   - Pros: lower migration risk for anyone still using the old prototype.
   - Cons: keeps the old target alive; increases maintenance and makes acceptance criteria ambiguous.
   - Effort: Medium/High

## Recommendation

Choose **Full VS Code/Copilot migration**. The current Cursor prototype is explicitly a baseline, and the official docs already give the main primitives needed for the harness: repo instructions, prompt files, custom agents, frontmatter, and handoffs. The bootstrap should pivot its default output and docs to VS Code/Copilot, while preserving the Pegasus SDD/memory workflow.

## Risks

- The docs clearly cover repository-level instructions and custom agents, but the exact equivalent of Cursor’s global rules is not 1:1.
- `chat.instructionsFilesLocations` suggests user-level instruction locations, but the exact bootstrap path and stability of that setting need verification before auto-installing anything globally.
- Agent/subagent behavior is documented, but the exact split between `.agent.md` and prompt-file `agent` / `runSubagent` usage needs a clear project convention.
- Generated artifacts must stop mentioning Cursor in completion text and public guidance; missing one reference would leave the new target inconsistent.

## Ready for Proposal

Yes — with one open question: whether the bootstrap should provide any user-global Copilot installation path at all, or stay repository-only for the first migration slice.
