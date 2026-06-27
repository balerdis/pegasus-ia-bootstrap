# Explore Addendum: Safe global/user install strategy for VS Code Copilot customizations

This addendum resolves the bootstrap risk around user-level VS Code/Copilot customization files. The safe default is **repository-only output**; any user/profile mutation must be an explicit opt-in with dry-run and backup behavior.

## Documented facts

| Source | Exact documented fact | Bootstrap implication |
|---|---|---|
| https://code.visualstudio.com/docs/copilot/customization/custom-agents | Custom agents can be stored in the workspace or at the user level. Default locations: `.github/agents` for workspace, `.claude/agents` for Claude format, and `~/.copilot/agents` or user data specific to the VS Code profile for user-level agents. `chat.agentFilesLocations` can add workspace search locations. `chat.useCustomizationsInParentRepositories` enables parent-repo discovery. | The bootstrap can safely write agent files to a Pegasus-managed directory, but VS Code must be pointed at that location through settings if it is outside the documented defaults. |
| https://code.visualstudio.com/docs/copilot/customization/custom-instructions | `.github/copilot-instructions.md` is workspace-wide. `.instructions.md` files can live in workspace folders or user profile locations. Default locations include `.github/instructions`, `~/.copilot/instructions`, `~/.claude/rules`, or user data specific to the VS Code profile. `chat.instructionsFilesLocations` enables/disables search locations. `github.copilot.chat.organizationInstructions.enabled` controls org-level instruction discovery. | User-level instruction files are supported, but bootstrap should not assume a single hardcoded path for all VS Code variants or profiles. |
| https://code.visualstudio.com/docs/copilot/customization/prompt-files | Prompt files are workspace-scoped by default in `.github/prompts` and can also be user-level via user data specific to the VS Code profile. `chat.promptFilesLocations` controls search locations. `chat.useCustomizationsInParentRepositories` enables parent-repo discovery. | Prompt files can be managed safely in a Pegasus-owned location if the user settings are updated to include that location. |
| https://code.visualstudio.com/docs/agents/reference/ai-settings | `chat.agentFilesLocations`, `chat.instructionsFilesLocations`, and `chat.promptFilesLocations` all accept folder/file search locations. `~` expansion is documented for agent locations and instructions settings. `chat.useCustomizationsInParentRepositories` is the documented monorepo discovery switch. | A bootstrap can update VS Code settings to include Pegasus-managed paths, but it should do so only with explicit permission and a backup. |
| https://code.visualstudio.com/docs/configure/settings | VS Code stores settings in `settings.json`. The file can be opened and edited directly with **Preferences: Open User Settings (JSON)**. On Linux, the documented Stable path is `~/.config/Code/User/settings.json`. | Direct user-settings editing is documented and safe when performed carefully; on Linux Stable, this is the canonical location to update. |
| https://code.visualstudio.com/docs/configure/settings-sync | Stable and Insiders use different Settings Sync services by default; they do not share settings unless the user chooses to sync Insiders with Stable. | Treat Stable and Insiders as separate targets. Do not assume one settings file or sync state covers both. |

## Recommended convention for Pegasus IA

1. **Write Copilot assets into a Pegasus-managed user directory** rather than into VS Code profile data directly.
   - Suggested root: `~/.config/pegasus-ia/copilot/`
   - Suggested subpaths: `agents/`, `instructions/`, `prompts/`
2. **Do not mutate VS Code user settings by default.**
   - Default behavior should print the exact manual steps instead.
3. **Provide an explicit opt-in flag for user-profile installation.**
   - When enabled, update the active VS Code user `settings.json` to include the Pegasus-managed paths in:
     - `chat.agentFilesLocations`
     - `chat.instructionsFilesLocations`
     - `chat.promptFilesLocations`
     - `chat.useCustomizationsInParentRepositories` (only if the user wants parent-repo discovery)
4. **Back up before writing any user settings.**
   - Preserve the prior `settings.json` and emit the backup path.
5. **Treat Stable and Insiders separately.**
   - Resolve the active profile/app target instead of hardcoding one global path.

## Unknowns and risks

- The docs give a stable Linux `settings.json` path, but the cited pages do not provide one canonical filesystem path for every Insiders scenario.
- Prompt files are documented as workspace/user scoped; there is no documented org-level prompt-file equivalent in the cited sources.
- A bootstrap that edits user settings must merge JSON objects carefully so existing customizations are preserved.
- Org-level instructions and custom agents are documented, but org-level onboarding does not solve a local bootstrap’s need to configure a specific machine safely.

## Spec-ready acceptance bullets

- The bootstrap MUST support a dry-run mode that prints proposed Copilot asset paths and any VS Code setting changes.
- The bootstrap MUST NOT modify VS Code user settings unless an explicit user-profile install flag is provided.
- When user-profile install is enabled, the bootstrap MUST back up the existing `settings.json` before writing changes.
- The bootstrap MUST add Pegasus-managed paths to `chat.agentFilesLocations`, `chat.instructionsFilesLocations`, and `chat.promptFilesLocations` without removing existing entries.
- The bootstrap SHOULD default to repository-only customization output and MAY offer a separate opt-in path for user-level installation.
- The bootstrap MUST treat Stable and Insiders as separate targets and MUST resolve the correct user settings file for the active installation.
- The bootstrap MUST preserve existing user customization files and MUST report every created, updated, or backed-up path.

## Decision summary

Use a **repository-first** default, with **explicit user-profile opt-in** for any VS Code settings mutation. This keeps the bootstrap safe, reversible, and compatible with the documented VS Code customization model.
