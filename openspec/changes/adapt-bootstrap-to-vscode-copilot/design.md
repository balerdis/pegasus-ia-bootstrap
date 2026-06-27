# Design: Adapt Bootstrap to VS Code/Copilot

## Technical Approach

Keep the current local-first Python CLI/template model, but make VS Code/Copilot the primary generated surface. The default workspace writes `.github/` Copilot assets, retained `AGENTS.md`, retained `docs/pegasus/`, and secondary legacy `.cursor/` guidance. No app, Git, CI, deploy, network, or MCP resources are created.

## Architecture Decisions

| Decision | Choice | Alternatives considered | Rationale |
|---|---|---|---|
| Primary layout | Generate `.github/copilot-instructions.md`, `.github/instructions/`, `.github/prompts/`, `.github/agents/`, `AGENTS.md`, `docs/pegasus/`, and legacy `.cursor/`. | Replace `AGENTS.md` or remove Cursor files. | Copilot gets native entry points while portable and legacy guidance remain safe. |
| Agent model | Make `pegasus-orchestrator.agent.md` visible/user-invocable; SDD phase and selected OpenCode-inspired agents are secondary/non-primary. Exclude `review-risk` and `review-readability`. | One huge instruction file; all agents visible. | Keeps the user entry point clear and prevents unsupported parity claims. |
| Copilot mapping | Map OpenCode concepts to Copilot frontmatter only where supported: `tools`, `agents`, `handoffs`, `user-invocable`, plus prose constraints for gaps. | Claim 1:1 OpenCode behavior. | VS Code/Copilot semantics differ; design must be explicit about approximations. |
| Global install | Add explicit VS Code/Copilot opt-in using Pegasus-managed `~/.config/pegasus-ia/copilot/{agents,instructions,prompts}/`. | Write directly to VS Code profile locations by default. | Safer, reversible, and compatible with documented search-location settings. |
| Legacy Cursor | Keep `--install-cursor-global` and Cursor templates as legacy secondary behavior. | Remove Cursor flags now. | The spec requires compatibility; removal is a later breaking change. |

## Data Flow

```text
CLI args ──→ validate target/project/options ──→ template inventory
   │                    │                           │
   │                    ├── workspace plan ─────────┤
   │                    └── optional global plan ───┤
   └── dry-run? print plan only                     ↓
                    conflict check ──→ write files / settings backups ──→ report paths
```

## File Changes

| File | Action | Description |
|---|---|---|
| `bin/pegasus-harness-bootstrap` | Modify | Rename messaging to Copilot-first, add `--install-copilot-global`, `--vscode-target stable|insiders`, keep `--install-cursor-global`, extend dry-run and reporting. |
| `templates/harness/.github/copilot-instructions.md` | Create | Workspace-wide Pegasus/Copilot instructions. |
| `templates/harness/.github/instructions/*.instructions.md` | Create | Scoped workflow, memory, SDD, and boundary instructions. |
| `templates/harness/.github/prompts/*.prompt.md` | Create | SDD phase prompts referencing `docs/pegasus` templates. |
| `templates/harness/.github/agents/*.agent.md` | Create | Orchestrator plus secondary SDD/OpenCode-inspired agents. |
| `templates/harness/AGENTS.md` | Modify | Portable guidance points to VS Code/Copilot first and Markdown memory. |
| `templates/harness/.cursor/rules/*` | Modify | Mark as legacy compatibility; point primary flow to `.github/`. |
| `templates/copilot-global/` | Create | Global/user Copilot assets copied into Pegasus-managed root. |
| `templates/cursor-global/` | Modify | Retain as legacy only. |
| `README.md`, `tests/smoke.sh` | Modify | Document and verify Copilot-first defaults, global install, and legacy behavior. |
| `openspec/specs/pegasus-harness-bootstrap/spec.md` | Modify | Sync stable spec during archive, not implementation. |

## Interfaces / Contracts

- CLI keeps `--project-name`, `--target-path`, `--dry-run`, `--force`.
- New flags: `--install-copilot-global`, `--vscode-target stable|insiders`; optional future `--vscode-settings-path` only for tests/advanced recovery.
- Legacy flag: `--install-cursor-global` remains accepted and reported as legacy.
- Settings merge contract: parse existing JSON object or treat missing file as `{}`; back up existing `settings.json` before mutation; append Pegasus paths to `chat.agentFilesLocations`, `chat.instructionsFilesLocations`, and `chat.promptFilesLocations` without removing existing entries.
- Stable/Insiders are separate targets: Linux defaults resolve to `~/.config/Code/User/settings.json` and `~/.config/Code - Insiders/User/settings.json`, respecting `XDG_CONFIG_HOME`.

## Testing Strategy

| Layer | What to Test | Approach |
|---|---|---|
| Smoke | Help, dry-run no writes, Copilot layout, conflict/force, banned public references, no `.git`. | Extend `tests/smoke.sh` with temp targets. |
| Smoke | Global Copilot dry-run/install/update/backups/settings merge for Stable and Insiders. | Use isolated `HOME`/`XDG_CONFIG_HOME`; inspect JSON and reported paths. |
| Manual | VS Code discovers added agent/instruction/prompt locations. | Verify Stable and Insiders settings behavior in real VS Code after implementation. |

## Migration / Rollout

Default output changes to Copilot-first in one release. Cursor workspace and global install remain legacy-compatible. Existing target files are preserved unless `--force` is used; conflicts are reported and stop writes.

## Risks and Tradeoffs

- Copilot custom agent behavior is not OpenCode parity; mitigate with conservative frontmatter and explicit prose.
- JSON settings mutation can damage user config; mitigate with opt-in, backups, dry-run, and non-destructive merge.
- Generated agent/template count can exceed review budget; split implementation into: CLI planning, workspace Copilot templates, global install/settings, docs/tests, then legacy cleanup.

## Open Questions

None blocking.
