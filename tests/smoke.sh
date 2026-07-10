#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI="$ROOT/bin/pegasus-harness-bootstrap"
PYTHON_BIN="${PYTHON_BIN:-python3}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export PEGASUS_MEMORY_MCP_ROOT="$TMP/pegasus-memory-mcp"
export PEGASUS_MEMORY_MCP_SKIP_INSTALL=1

VENV="$TMP/editable-venv"
"$PYTHON_BIN" -m venv "$VENV"
"$VENV/bin/python" -m pip install -e "$ROOT" >/dev/null
ENTRYPOINT="$VENV/bin/pegasus-harness-bootstrap"

assert_file_contains() {
  local file="$1"
  local text="$2"
  grep -Fq "$text" "$file" || {
    printf 'Expected %s to contain %s\n' "$file" "$text" >&2
    exit 1
  }
}

assert_no_banned_markdown_memory_persistence_refs() {
  local root="$1"
  local banned_pattern='docs/pegasus/memory/(context|tasks-log|decisions|handoff|learnings)\.md|read from docs/pegasus/memory|write to docs/pegasus/memory|update docs/pegasus/memory|Markdown memory source of truth|Markdown memory backend'
  if grep -R -E "$banned_pattern" "$root" >/dev/null; then
    printf 'generated harness contains banned Markdown-memory persistence references\n' >&2
    grep -R -E "$banned_pattern" "$root" >&2
    exit 1
  fi
}

expected_files=(
  "AGENTS.md"
  ".vscode/mcp.json"
  ".github/copilot-instructions.md"
  ".github/instructions/pegasus-workflow.instructions.md"
  ".github/instructions/pegasus-memory.instructions.md"
  ".github/instructions/pegasus-sdd-boundaries.instructions.md"
  ".github/instructions/pegasus-local-first.instructions.md"
  ".github/instructions/pegasus-legacy-compatibility.instructions.md"
  ".github/prompts/sdd-phases.prompt.md"
  ".github/prompts/handoff.prompt.md"
  ".github/prompts/memory-update.prompt.md"
  ".github/agents/pegasus-orchestrator.agent.md"
  ".github/agents/sdd-proposal.agent.md"
  ".github/agents/sdd-spec.agent.md"
  ".github/agents/sdd-design.agent.md"
  ".github/agents/sdd-tasks.agent.md"
  ".github/agents/sdd-apply.agent.md"
  ".github/agents/sdd-verify.agent.md"
  ".github/agents/session-handoff.agent.md"
  ".github/agents/memory-maintainer.agent.md"
  ".github/agents/doc-designer.agent.md"
  ".cursor/rules/pegasus-memory.mdc"
  ".cursor/rules/pegasus-workflow.mdc"
  ".pegasus-bootstrap-ia/manifest.json"
  "docs/pegasus/prd.md"
  "docs/pegasus/proposal.md"
  "docs/pegasus/spec.md"
  "docs/pegasus/design.md"
  "docs/pegasus/tasks.md"
  "docs/pegasus/apply-progress.md"
  "docs/pegasus/verify.md"
)

chmod +x "$CLI"

editable_plan="$($ENTRYPOINT --project-name demo --target-path "$TMP/editable-demo" --dry-run)"
case "$editable_plan" in
  *"Project: demo"*"Target: $TMP/editable-demo"*"Dry run only; no files were written."*) ;;
  *) printf 'expected editable entry point to run dry-run setup\n' >&2; exit 1 ;;
esac

wrapper_plan="$($CLI --project-name demo --target-path "$TMP/wrapper-demo" --dry-run)"
case "$wrapper_plan" in
  *"Project: demo"*"Target: $TMP/wrapper-demo"*"Dry run only; no files were written."*) ;;
  *) printf 'expected bin compatibility wrapper to run dry-run setup\n' >&2; exit 1 ;;
esac

"$CLI" --help >/dev/null
"$PYTHON_BIN" "$CLI" --help >/dev/null
help_output="$($PYTHON_BIN "$CLI" --help)"
case "$help_output" in
  *"--install-cursor-global"*) ;;
  *) printf 'expected help output to include --install-cursor-global\n' >&2; exit 1 ;;
esac
case "$help_output" in
  *"--install-copilot-global"*"--vscode-target"*) ;;
  *) printf 'expected help output to include Copilot global planning flags\n' >&2; exit 1 ;;
esac
case "$help_output" in
  *"--install-memory-mcp"*) ;;
  *) printf 'expected help output to include memory MCP planning flag\n' >&2; exit 1 ;;
esac
case "$help_output" in
  *"--uninstall-workspace"*"--uninstall-copilot-global"*) ;;
  *) printf 'expected help output to include uninstall lifecycle flags\n' >&2; exit 1 ;;
esac
case "$help_output" in
  *"--new-change"*) ;;
  *) printf 'expected help output to include new-change lifecycle flag\n' >&2; exit 1 ;;
esac
case "$help_output" in
  *"--sync-workspace"*"--overwrite-conflicts"*) ;;
  *) printf 'expected help output to include workspace sync flags\n' >&2; exit 1 ;;
esac
assert_file_contains "$ROOT/pegasus_harness_bootstrap/cli.py" 'MEMORY_MCP_BRANCH = "stable/0.1.1"'

if initial_setup_without_project_output="$($PYTHON_BIN "$CLI" --target-path "$TMP/no-project-setup" --dry-run 2>&1)"; then
  printf 'initial setup without --project-name should fail\n' >&2
  exit 1
fi
case "$initial_setup_without_project_output" in
  *"--project-name is required unless --sync-workspace, --new-change, or an uninstall flag is used"*) ;;
  *) printf 'expected clear missing project-name setup error\n' >&2; exit 1 ;;
esac
if initial_setup_without_project_or_target_output="$($PYTHON_BIN "$CLI" --dry-run 2>&1)"; then
  printf 'initial setup without --project-name or --target-path should fail\n' >&2
  exit 1
fi
case "$initial_setup_without_project_or_target_output" in
  *"--project-name is required unless --sync-workspace, --new-change, or an uninstall flag is used"*) ;;
  *) printf 'expected clear missing project-name setup error without target path\n' >&2; exit 1 ;;
esac

default_plan="$($PYTHON_BIN "$CLI" --project-name default-project --dry-run)"
case "$default_plan" in
  *"Target: /var/www/html/personal/default-project"*) ;;
  *) printf 'expected default target path in dry-run output\n' >&2; exit 1 ;;
esac
case "$default_plan" in
  *"Primary IDE: VS Code with GitHub Copilot"*".github/copilot-instructions.md"*"AGENTS.md"*"docs/pegasus"*".cursor"*) ;;
  *) printf 'expected dry-run output to list Copilot-first and legacy workspace surfaces\n' >&2; exit 1 ;;
esac
case "$default_plan" in
  *"Pegasus Memory MCP workspace stdio setup (default-on):"*"Command: node"*"Script: $PEGASUS_MEMORY_MCP_ROOT/dist/bin/pegasus-memory-mcp.js"*"Cwd: $PEGASUS_MEMORY_MCP_ROOT"*"Source: unavailable"*) ;;
  *) printf 'expected dry-run output to include default-on memory MCP stdio planning\n' >&2; exit 1 ;;
esac
explicit_memory_plan="$($PYTHON_BIN "$CLI" --project-name explicit-memory --target-path "$TMP/explicit-memory" --install-memory-mcp --dry-run)"
case "$explicit_memory_plan" in
  *"Pegasus Memory MCP workspace stdio setup (explicit):"*"Command: node"*) ;;
  *) printf 'expected explicit memory MCP planning output\n' >&2; exit 1 ;;
esac
assert_file_contains "$ROOT/pyproject.toml" 'templates/harness/.vscode/*.json'
case "$default_plan" in
  *"Open the target workspace in Cursor"*) printf 'default dry-run should not present Cursor as the primary next step\n' >&2; exit 1 ;;
  *) ;;
esac

dry_target="$TMP/dry-run-project"
"$PYTHON_BIN" "$CLI" --project-name dry-run-project --target-path "$dry_target" --dry-run >/dev/null
[ ! -e "$dry_target" ] || { printf 'dry-run wrote files\n' >&2; exit 1; }

missing_confirm_target="$TMP/missing-confirm-target"
if missing_decline_output="$(printf 'no\n' | "$PYTHON_BIN" "$CLI" --project-name missing-confirm --target-path "$missing_confirm_target" 2>&1)"; then
  printf 'expected missing explicit target setup to require confirmation\n' >&2
  exit 1
fi
case "$missing_decline_output" in
  *"Explicit target path does not exist: $missing_confirm_target"*"target path creation cancelled: $missing_confirm_target"*) ;;
  *) printf 'expected missing target cancellation output with exact path\n' >&2; exit 1 ;;
esac
[ ! -e "$missing_confirm_target" ] || { printf 'declined missing target confirmation wrote files\n' >&2; exit 1; }

missing_confirm_yes_target="$TMP/missing-confirm-yes-target"
missing_confirm_yes_output="$(printf 'yes\n' | "$PYTHON_BIN" "$CLI" --project-name missing-confirm-yes --target-path "$missing_confirm_yes_target")"
case "$missing_confirm_yes_output" in
  *"Explicit target path does not exist: $missing_confirm_yes_target"*"Completed Pegasus VS Code/Copilot harness bootstrap."*) ;;
  *) printf 'expected accepted missing target confirmation output with exact path\n' >&2; exit 1 ;;
esac
[ -f "$missing_confirm_yes_target/AGENTS.md" ] || { printf 'accepted missing target confirmation did not write harness\n' >&2; exit 1; }

default_home="$TMP/default-home"
default_xdg="$TMP/default-xdg"
default_target="$TMP/default-no-global"
mkdir -p "$default_home" "$default_xdg"
default_run_output="$(printf 'yes\n' | HOME="$default_home" XDG_CONFIG_HOME="$default_xdg" "$PYTHON_BIN" "$CLI" --project-name default-no-global --target-path "$default_target")"
[ -f "$default_target/AGENTS.md" ] || { printf 'default run did not create target harness\n' >&2; exit 1; }
[ ! -e "$default_xdg/Cursor" ] || { printf 'default run touched XDG Cursor config\n' >&2; exit 1; }
[ ! -e "$default_home/.config/Cursor" ] || { printf 'default run touched HOME Cursor config\n' >&2; exit 1; }
[ ! -e "$default_home/.cursor" ] || { printf 'default run touched legacy Cursor config\n' >&2; exit 1; }
[ ! -e "$default_xdg/Code" ] || { printf 'default run touched VS Code Stable config\n' >&2; exit 1; }
[ ! -e "$default_xdg/Code - Insiders" ] || { printf 'default run touched VS Code Insiders config\n' >&2; exit 1; }
[ ! -e "$default_xdg/pegasus-ia" ] || { printf 'default run touched Pegasus-managed Copilot config\n' >&2; exit 1; }
case "$default_run_output" in
  *"Open the target workspace in VS Code with Copilot"*"Primary Copilot entry point: .github/agents/pegasus-orchestrator.agent.md"*) ;;
  *) printf 'expected default completion output to point to VS Code/Copilot and the Pegasus orchestrator\n' >&2; exit 1 ;;
esac
case "$default_run_output" in
  *"El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente"*) ;;
  *) printf 'expected default run to warn when memory MCP is unavailable\n' >&2; exit 1 ;;
esac
case "$default_run_output" in
  *"Open the target workspace in Cursor"*) printf 'default completion should not present Cursor as the primary next step\n' >&2; exit 1 ;;
  *) ;;
esac

copilot_home="$TMP/copilot-home"
copilot_xdg="$TMP/copilot-xdg"
copilot_target="$TMP/copilot-dry-target"
mkdir -p "$copilot_home" "$copilot_xdg"
copilot_dry_output="$(HOME="$copilot_home" XDG_CONFIG_HOME="$copilot_xdg" "$PYTHON_BIN" "$CLI" --project-name copilot-dry --target-path "$copilot_target" --install-copilot-global --vscode-target insiders --dry-run)"
case "$copilot_dry_output" in
  *"Global VS Code/Copilot configuration (--install-copilot-global):"*"VS Code target: insiders"*"$copilot_xdg/pegasus-ia/copilot"*"$copilot_xdg/Code - Insiders/User/settings.json"*"chat.agentFilesLocations"*) ;;
  *) printf 'expected Copilot global dry-run planning output\n' >&2; exit 1 ;;
esac
[ ! -e "$copilot_target" ] || { printf 'Copilot global dry-run wrote target files\n' >&2; exit 1; }
[ ! -e "$copilot_xdg/Code" ] || { printf 'Copilot global dry-run wrote VS Code stable config\n' >&2; exit 1; }
[ ! -e "$copilot_xdg/Code - Insiders" ] || { printf 'Copilot global dry-run wrote VS Code insiders config\n' >&2; exit 1; }
[ ! -e "$copilot_xdg/pegasus-ia" ] || { printf 'Copilot global dry-run wrote managed assets\n' >&2; exit 1; }

copilot_install_home="$TMP/copilot-install-home"
copilot_install_xdg="$TMP/copilot-install-xdg"
copilot_install_target="$TMP/copilot-install-target"
mkdir -p "$copilot_install_home" "$copilot_install_xdg"
copilot_install_output="$(printf 'yes\n' | HOME="$copilot_install_home" XDG_CONFIG_HOME="$copilot_install_xdg" "$PYTHON_BIN" "$CLI" --project-name copilot-install --target-path "$copilot_install_target" --install-copilot-global)"
[ -f "$copilot_install_xdg/pegasus-ia/copilot/agents/pegasus-global-orchestrator.agent.md" ] || { printf 'expected Copilot global agent asset\n' >&2; exit 1; }
[ -f "$copilot_install_xdg/pegasus-ia/copilot/instructions/pegasus-global.instructions.md" ] || { printf 'expected Copilot global instruction asset\n' >&2; exit 1; }
[ -f "$copilot_install_xdg/pegasus-ia/copilot/prompts/pegasus-start.prompt.md" ] || { printf 'expected Copilot global prompt asset\n' >&2; exit 1; }
[ -f "$copilot_install_xdg/Code/User/settings.json" ] || { printf 'expected Stable settings file\n' >&2; exit 1; }
case "$copilot_install_output" in
  *"Updated global VS Code/Copilot assets: $copilot_install_xdg/pegasus-ia/copilot"*"Updated VS Code settings (stable): $copilot_install_xdg/Code/User/settings.json"*) ;;
  *) printf 'expected Copilot global install output to report paths\n' >&2; exit 1 ;;
esac
"$PYTHON_BIN" - "$copilot_install_xdg" <<'PY'
import json
import sys
from pathlib import Path
xdg = Path(sys.argv[1])
settings = json.loads((xdg / "Code/User/settings.json").read_text())
root = xdg / "pegasus-ia/copilot"
assert settings["chat.agentFilesLocations"][str(root / "agents")] is True
assert settings["chat.instructionsFilesLocations"][str(root / "instructions")] is True
assert settings["chat.promptFilesLocations"][str(root / "prompts")] is True
PY

copilot_insiders_home="$TMP/copilot-insiders-home"
copilot_insiders_xdg="$TMP/copilot-insiders-xdg"
copilot_insiders_target="$TMP/copilot-insiders-target"
mkdir -p "$copilot_insiders_home" "$copilot_insiders_xdg"
printf 'yes\n' | HOME="$copilot_insiders_home" XDG_CONFIG_HOME="$copilot_insiders_xdg" "$PYTHON_BIN" "$CLI" --project-name copilot-insiders --target-path "$copilot_insiders_target" --install-copilot-global --vscode-target insiders >/dev/null
[ -f "$copilot_insiders_xdg/Code - Insiders/User/settings.json" ] || { printf 'expected Insiders settings file\n' >&2; exit 1; }
[ ! -e "$copilot_insiders_xdg/Code/User/settings.json" ] || { printf 'Insiders install wrote Stable settings\n' >&2; exit 1; }

merge_home="$TMP/copilot-merge-home"
merge_xdg="$TMP/copilot-merge-xdg"
merge_target="$TMP/copilot-merge-target"
mkdir -p "$merge_home" "$merge_xdg/Code/User"
cat > "$merge_xdg/Code/User/settings.json" <<'JSON'
{
  "editor.fontSize": 15,
  "chat.agentFilesLocations": {
    "/existing/agents": true
  },
  "chat.instructionsFilesLocations": {
    "/existing/instructions": false
  },
  "chat.promptFilesLocations": ["/existing/prompts"]
}
JSON
merge_output="$(printf 'yes\n' | HOME="$merge_home" XDG_CONFIG_HOME="$merge_xdg" "$PYTHON_BIN" "$CLI" --project-name copilot-merge --target-path "$merge_target" --install-copilot-global)"
case "$merge_output" in
  *"Backup created: $merge_xdg/Code/User/settings.json."*".bak"*) ;;
  *) printf 'expected Copilot settings backup output\n' >&2; exit 1 ;;
esac
merge_backup_count=$(compgen -G "$merge_xdg/Code/User/settings.json.*.bak" | wc -l)
[ "$merge_backup_count" -ge 1 ] || { printf 'expected Copilot settings backup file\n' >&2; exit 1; }
"$PYTHON_BIN" - "$merge_xdg" <<'PY'
import json
import sys
from pathlib import Path
xdg = Path(sys.argv[1])
settings = json.loads((xdg / "Code/User/settings.json").read_text())
root = xdg / "pegasus-ia/copilot"
assert settings["editor.fontSize"] == 15
assert settings["chat.agentFilesLocations"]["/existing/agents"] is True
assert settings["chat.agentFilesLocations"][str(root / "agents")] is True
assert settings["chat.instructionsFilesLocations"]["/existing/instructions"] is False
assert settings["chat.instructionsFilesLocations"][str(root / "instructions")] is True
assert "/existing/prompts" in settings["chat.promptFilesLocations"]
assert str(root / "prompts") in settings["chat.promptFilesLocations"]
PY
assert_file_contains "$(compgen -G "$merge_xdg/Code/User/settings.json.*.bak" | sort | tail -n 1)" '"editor.fontSize": 15'

invalid_home="$TMP/copilot-invalid-home"
invalid_xdg="$TMP/copilot-invalid-xdg"
invalid_target="$TMP/copilot-invalid-target"
mkdir -p "$invalid_home" "$invalid_xdg/Code/User" "$invalid_xdg/pegasus-ia/copilot/agents"
printf '{ invalid json\n' > "$invalid_xdg/Code/User/settings.json"
printf 'existing managed asset\n' > "$invalid_xdg/pegasus-ia/copilot/agents/pegasus-global-orchestrator.agent.md"
if invalid_output="$(HOME="$invalid_home" XDG_CONFIG_HOME="$invalid_xdg" "$PYTHON_BIN" "$CLI" --project-name copilot-invalid --target-path "$invalid_target" --install-copilot-global 2>&1)"; then
  printf 'expected invalid settings JSON failure\n' >&2
  exit 1
fi
case "$invalid_output" in
  *"invalid VS Code settings JSON"*) ;;
  *) printf 'expected clear invalid settings JSON error\n' >&2; exit 1 ;;
esac
assert_file_contains "$invalid_xdg/Code/User/settings.json" '{ invalid json'
[ ! -e "$invalid_target" ] || { printf 'invalid settings JSON should not create target workspace\n' >&2; exit 1; }
assert_file_contains "$invalid_xdg/pegasus-ia/copilot/agents/pegasus-global-orchestrator.agent.md" 'existing managed asset'
if grep -Fq 'PEGASUS-COPILOT-GLOBAL' "$invalid_xdg/pegasus-ia/copilot/agents/pegasus-global-orchestrator.agent.md"; then
  printf 'invalid settings JSON should not overwrite managed Copilot assets\n' >&2
  exit 1
fi
[ ! -e "$invalid_xdg/pegasus-ia/copilot/instructions" ] || { printf 'invalid settings JSON should not create managed instruction assets\n' >&2; exit 1; }
[ ! -e "$invalid_xdg/pegasus-ia/copilot/prompts" ] || { printf 'invalid settings JSON should not create managed prompt assets\n' >&2; exit 1; }
if compgen -G "$invalid_xdg/Code/User/settings.json.*.bak" >/dev/null; then
  printf 'invalid settings JSON should not create backup\n' >&2
  exit 1
fi

target="$TMP/sample-project"
printf 'yes\n' | "$PYTHON_BIN" "$CLI" --project-name sample-project --target-path "$target" >/dev/null
for file in "${expected_files[@]}"; do
  [ -f "$target/$file" ] || { printf 'expected generated file %s\n' "$file" >&2; exit 1; }
done
assert_file_contains "$target/AGENTS.md" "sample-project"
assert_file_contains "$target/AGENTS.md" "$target"
assert_file_contains "$target/AGENTS.md" ".github/agents/pegasus-orchestrator.agent.md"
assert_file_contains "$target/.github/copilot-instructions.md" "Primary entry point"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "name: pegasus-orchestrator"
assert_file_contains "$target/.github/agents/sdd-apply.agent.md" "user-invocable: false"
assert_file_contains "$target/.github/agents/doc-designer.agent.md" "PRD and discovery contract"
assert_file_contains "$target/.github/agents/doc-designer.agent.md" "Do not write technical design"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "Proposal-only contract"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "Stop before spec, design, and tasks"
assert_file_contains "$target/docs/pegasus/prd.md" "Current Situation / Gap"
assert_file_contains "$target/docs/pegasus/prd.md" "Approval Owner"
assert_file_contains "$target/docs/pegasus/proposal.md" "PRD Source / Status"
assert_file_contains "$target/docs/pegasus/proposal.md" "Explicit Exclusions"
assert_file_contains "$target/docs/pegasus/apply-progress.md" "Current In-Progress Work"
assert_file_contains "$target/docs/pegasus/apply-progress.md" "Merge updates into the existing useful history"
assert_file_contains "$target/.github/agents/sdd-verify.agent.md" "Verify from fresh context when possible"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "Launch deduplication"
assert_file_contains "$target/.github/agents/memory-maintainer.agent.md" 'Record operational memory through `pegasus-memory-mcp`'
assert_file_contains "$target/.github/agents/memory-maintainer.agent.md" "Before the first recovery or save attempt, call the MCP \`health\` tool"
assert_file_contains "$target/.github/agents/memory-maintainer.agent.md" "do not claim persistent memory was saved"
assert_file_contains "$target/.github/agents/memory-maintainer.agent.md" "not_found"
assert_file_contains "$target/.github/agents/memory-maintainer.agent.md" "ambiguous"
assert_file_contains "$target/.github/agents/memory-maintainer.agent.md" "read_error"
assert_file_contains "$target/.github/agents/memory-maintainer.agent.md" "persistence_error"
assert_file_contains "$target/.github/agents/memory-maintainer.agent.md" "ensure_project"
assert_file_contains "$target/.github/agents/memory-maintainer.agent.md" "ensure_change"
assert_file_contains "$target/.github/agents/memory-maintainer.agent.md" "project_not_found"
assert_file_contains "$target/.github/prompts/memory-update.prompt.md" "Do not write retrospective Markdown memory"
assert_file_contains "$target/.github/prompts/memory-update.prompt.md" "call the \`pegasus-memory-mcp\` \`health\` tool before the first recovery or save attempt"
assert_file_contains "$target/.github/prompts/memory-update.prompt.md" "Preserve MCP consumer states: \`not_found\`, \`ambiguous\`, \`read_error\`, and \`persistence_error\`"
assert_file_contains "$target/.github/prompts/memory-update.prompt.md" "ensure_project"
assert_file_contains "$target/.github/prompts/memory-update.prompt.md" "ensure_change"
assert_file_contains "$target/.cursor/rules/pegasus-memory.mdc" "Recover active project/change context through MCP"
assert_file_contains "$target/.cursor/rules/pegasus-workflow.mdc" "secondary legacy Cursor compatibility guidance"
assert_file_contains "$target/.cursor/rules/pegasus-workflow.mdc" "do not fall back to Markdown memory"
assert_file_contains "$target/AGENTS.md" 'El pegasus-memory-mcp no se encuentra disponible, si continuamos con eso asi, no se guardara nada de lo que hagamos en memoria persistente'
assert_file_contains "$target/AGENTS.md" "MCP-first operational memory"
assert_file_contains "$target/AGENTS.md" "pegasus-harness:start path=AGENTS.md ownership=marker-managed"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "pegasus-harness:start path=.github/agents/pegasus-orchestrator.agent.md ownership=full-file"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "call the \`pegasus-memory-mcp\` \`health\` tool before the first recovery attempt"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "call \`health\` before the first save"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "Natural-language PRD intent"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "quiero armar un PRD para esta idea"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "Before editing or finalizing any PRD, identify open product/business decisions."
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "do not silently decide product scope"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" 'Run `git diff` only when the workspace has a `.git` directory'
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" 'If any required persistence call failed, say the PRD is file-only and include the reason.'
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "Tell the user the PRD file path (\`docs/pegasus/prd.md\`, \`docs/pegasus/changes/<change-id>/prd.md\`, or the full path when useful) and ask them to review it."
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "Wait for explicit user approval of the PRD before moving to proposal, spec, design, tasks, apply, or verify."
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "save PRD status, product decisions, questions/answers, and the artifact reference through MCP"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "Do not implement code, create technical design, write tasks, or advance to proposal/spec/design/tasks/apply during PRD flow."
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "ensure_project"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "ensure_change"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "project_not_found"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "# MCP-first memory"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "Call the MCP \`health\` tool before the first recovery or save attempt"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "Save proactively after important changes"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "bugfixes, root causes, and remediation notes"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "verification commands, evidence, deviations, verdicts, and remediation needs"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "handoffs and session summaries before ending or pausing work"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "After context compaction, context loss, or a long pause"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "save a concise handoff/session summary through MCP when healthy"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "do not fall back to Markdown memory"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "health.capabilities.parent_bootstrap"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "ensure_project"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "ensure_change"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "project_not_found"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "foreign-key failures"
assert_file_contains "$target/.github/copilot-instructions.md" "call the \`pegasus-memory-mcp\` \`health\` tool before the first recovery attempt"
assert_file_contains "$target/.github/copilot-instructions.md" "call \`health\` before the first MCP save attempt"
assert_file_contains "$target/.github/copilot-instructions.md" "proactively save durable decisions, bugfixes, discoveries/gotchas"
assert_file_contains "$target/.github/copilot-instructions.md" "Keep consumer states distinct: \`not_found\`"
assert_file_contains "$target/.github/copilot-instructions.md" "Natural-language PRD intent is enough to start PRD discovery."
assert_file_contains "$target/.github/copilot-instructions.md" "never silently decide product scope"
assert_file_contains "$target/.github/copilot-instructions.md" 'report whether `ensure_project`, `ensure_change`, `record_artifact`, and `record_observation` succeeded'
assert_file_contains "$target/.github/copilot-instructions.md" 'Run `git diff` only when the workspace has a `.git` directory'
assert_file_contains "$target/.github/copilot-instructions.md" "wait for explicit PRD approval before proposal/spec/design/tasks/apply, and do not implement code during PRD flow"
assert_file_contains "$target/.github/copilot-instructions.md" "ensure_project"
assert_file_contains "$target/.github/copilot-instructions.md" "ensure_change"
assert_file_contains "$target/.github/copilot-instructions.md" "project_not_found"
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" "Natural-language product intent should trigger PRD discovery automatically."
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" "tell the user the PRD file path and ask them to review it"
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" "product decisions are open"
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" 'record_artifact`, and `record_observation` succeeded'
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" 'Run `git diff` only when the workspace has a `.git` directory'
for memory_guided_agent in doc-designer sdd-proposal sdd-spec sdd-design sdd-tasks sdd-apply sdd-verify session-handoff memory-maintainer pegasus-orchestrator; do
  assert_file_contains "$target/.github/agents/$memory_guided_agent.agent.md" "pegasus-memory.instructions.md"
done
assert_file_contains "$target/.github/agents/doc-designer.agent.md" "PRD/product discoveries"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "proposal status, assumptions, scope decisions, risks"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "requirement decisions, scenario coverage, open questions"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "architecture decisions, tradeoffs, alternatives, risks"
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "task progress, blockers, review budget assessment"
assert_file_contains "$target/.github/agents/sdd-apply.agent.md" "implementation progress, blockers, changed files, tests/checks run"
assert_file_contains "$target/.github/agents/sdd-apply.agent.md" "merge updates instead of replacing useful history"
assert_file_contains "$target/.github/agents/sdd-verify.agent.md" "verification evidence, commands/results, deviations, final verdict"
assert_file_contains "$target/.github/agents/sdd-verify.agent.md" "merge updates instead of replacing useful history"
assert_file_contains "$target/.github/agents/session-handoff.agent.md" "handoff/session summary"
assert_file_contains "$target/.github/agents/memory-maintainer.agent.md" "Proactively save decisions, bugfixes, discoveries/gotchas"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "## Memory state"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "never expose MCP recovery mechanics as user-facing requirements"
assert_file_contains "$target/.github/prompts/handoff.prompt.md" "handoff/session summary"
assert_file_contains "$target/.github/prompts/memory-update.prompt.md" "Before ending or pausing, save a concise handoff/session summary after MCP \`health\` succeeds"
assert_file_contains "$target/.github/prompts/sdd-phases.prompt.md" "proactively save decisions, discoveries, bugfixes, config changes, user constraints, artifact status, task progress, verification evidence, and handoff/session summaries"
"$PYTHON_BIN" - "$target/.github" <<'PY'
import sys
from pathlib import Path

root = Path(sys.argv[1])
ambiguous = []
for path in sorted(root.rglob("*.md")):
    for line_number, line in enumerate(path.read_text().splitlines(), start=1):
        lower = line.lower()
        if "mcp" in lower and "when available" in lower and "health" not in lower:
            ambiguous.append(f"{path.relative_to(root)}:{line_number}: {line}")

if ambiguous:
    print("Generated .github MCP guidance must state the health precondition inline:", file=sys.stderr)
    print("\n".join(ambiguous), file=sys.stderr)
    raise SystemExit(1)
PY
"$PYTHON_BIN" - "$target/.vscode/mcp.json" "$PEGASUS_MEMORY_MCP_ROOT" "$PEGASUS_MEMORY_MCP_ROOT/dist/bin/pegasus-memory-mcp.js" <<'PY'
import json
import sys
from pathlib import Path

config = json.loads(Path(sys.argv[1]).read_text())
expected_root = Path(sys.argv[2])
expected_script = Path(sys.argv[3])
server = config["servers"]["pegasus-memory-mcp"]
assert server["command"] == "node"
assert server["cwd"] == str(expected_root)
assert server["args"] == [str(expected_script)]
assert Path(server["cwd"]).is_absolute()
assert Path(server["args"][0]).is_absolute()
assert Path(server["args"][0]).parent.parent.parent == Path(server["cwd"])
PY
[ ! -e "$target/docs/pegasus/memory" ] || { printf 'generated harness should not include docs/pegasus/memory\n' >&2; exit 1; }
assert_no_banned_markdown_memory_persistence_refs "$target"
"$PYTHON_BIN" - "$target/.pegasus-bootstrap-ia/manifest.json" <<'PY'
import json
import sys
from pathlib import Path

manifest = json.loads(Path(sys.argv[1]).read_text())
manifest_text = json.dumps(manifest)
for forbidden in ("active_change", "activeChange", "last_change", "lastChange", "operational_memory", "operationalMemory", "memory_state", "memoryState", "recovery_state", "recoveryState"):
    assert forbidden not in manifest_text
assert manifest["workspace"]["project_name"] == "sample-project"
assert manifest["uninstall"]["remove_only_managed"] is True
paths = {record["path"]: record for record in manifest["install"]["files"]}
assert "AGENTS.md" in paths
assert ".vscode/mcp.json" in paths
assert paths["AGENTS.md"]["ownership"] == "marker-managed"
assert paths[".vscode/mcp.json"]["ownership"] == "full-file"
assert paths[".github/agents/pegasus-orchestrator.agent.md"]["ownership"] == "full-file"
assert manifest["install"]["skipped_conflicts"] == []
PY

new_change_output="$($PYTHON_BIN "$CLI" --new-change feature-a --target-path "$target")"
case "$new_change_output" in
  *"Created Pegasus change PRD."*"Change: feature-a"*"$target/docs/pegasus/changes/feature-a/prd.md"*) ;;
  *) printf 'expected new-change output to report PRD-only creation\n' >&2; exit 1 ;;
esac
[ -f "$target/docs/pegasus/changes/feature-a/prd.md" ] || { printf 'new-change did not create prd.md\n' >&2; exit 1; }
assert_file_contains "$target/docs/pegasus/changes/feature-a/prd.md" "# PRD: feature-a"
assert_file_contains "$target/docs/pegasus/changes/feature-a/prd.md" 'Project: `sample-project`'
for unexpected in proposal spec design tasks apply-progress verify; do
  [ ! -e "$target/docs/pegasus/changes/feature-a/$unexpected.md" ] || {
    printf 'new-change created unexpected artifact %s.md\n' "$unexpected" >&2
    exit 1
  }
done
"$PYTHON_BIN" - "$target/.pegasus-bootstrap-ia/manifest.json" <<'PY'
import json
import sys
from pathlib import Path

manifest = json.loads(Path(sys.argv[1]).read_text())
manifest_text = json.dumps(manifest)
for forbidden in ("active_change", "activeChange", "last_change", "lastChange"):
    assert forbidden not in manifest_text
PY

if "$PYTHON_BIN" "$CLI" --new-change missing-manifest --target-path "$TMP/not-installed" >/dev/null 2>&1; then
  printf 'new-change should require a Pegasus workspace manifest\n' >&2
  exit 1
fi

for agent in sdd-spec sdd-design sdd-tasks sdd-apply sdd-verify; do
  agent_file="$target/.github/agents/$agent.agent.md"
  assert_file_contains "$agent_file" "## Input contract"
  assert_file_contains "$agent_file" "## Required reads"
  assert_file_contains "$agent_file" "## Output contract"
  assert_file_contains "$agent_file" "## Stopping point"
  assert_file_contains "$agent_file" "## Forbidden scope"
  assert_file_contains "$agent_file" "## Phase-specific checklist"
done

assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "approved PRD and approved proposal"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" 'GIVEN` / `WHEN` / `THEN'
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "Do not design architecture"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Decisions, tradeoffs, and alternatives considered"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Do not implement code"
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "Decision needed before apply: Yes|No"
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "Chained PRs recommended: Yes|No"
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "400-line budget risk: Low|Medium|High"
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "Do not implement code"
assert_file_contains "$target/.github/agents/sdd-apply.agent.md" "approved next task slice"
assert_file_contains "$target/.github/agents/sdd-apply.agent.md" "duplicate-check result"
assert_file_contains "$target/.github/agents/sdd-apply.agent.md" 'preliminary apply evidence as a replacement for `sdd-verify`'
assert_file_contains "$target/.github/agents/sdd-verify.agent.md" "Compliance matrix against PRD, proposal, spec, design, and tasks"
assert_file_contains "$target/.github/agents/sdd-verify.agent.md" "No unrelated implementation changes were made"
assert_file_contains "$target/.github/agents/sdd-verify.agent.md" "Do not edit implementation code unless the user separately asks for remediation"

assert_file_contains "$target/docs/pegasus/spec.md" "## Source Status"
assert_file_contains "$target/docs/pegasus/spec.md" "## Acceptance Edge Cases"
assert_file_contains "$target/docs/pegasus/spec.md" "## Non-Goals / Out of Scope"
assert_file_contains "$target/docs/pegasus/spec.md" "## Traceability"
assert_file_contains "$target/docs/pegasus/design.md" "## Inputs"
assert_file_contains "$target/docs/pegasus/design.md" "## Design Goals / Non-Goals"
assert_file_contains "$target/docs/pegasus/design.md" "## Alternatives Considered"
assert_file_contains "$target/docs/pegasus/design.md" "## Data / Control Flow"
assert_file_contains "$target/docs/pegasus/design.md" "## Rollout / Rollback"
assert_file_contains "$target/docs/pegasus/tasks.md" "Decision needed before apply: Yes|No"
assert_file_contains "$target/docs/pegasus/tasks.md" "Chained PRs recommended: Yes|No"
assert_file_contains "$target/docs/pegasus/tasks.md" "400-line budget risk: Low|Medium|High"
assert_file_contains "$target/docs/pegasus/tasks.md" "### Example Slice: Apply deduplication guard"
assert_file_contains "$target/docs/pegasus/tasks.md" "## No Implementation in Tasks Phase"
assert_file_contains "$target/docs/pegasus/apply-progress.md" "Approved task slice source"
assert_file_contains "$target/docs/pegasus/apply-progress.md" "## Duplicate Check"
assert_file_contains "$target/docs/pegasus/apply-progress.md" "Verification status"
assert_file_contains "$target/docs/pegasus/apply-progress.md" "does not replace the verify phase"
assert_file_contains "$target/docs/pegasus/verify.md" "## Compliance Matrix"
assert_file_contains "$target/docs/pegasus/verify.md" "## Changed Files Reviewed"
assert_file_contains "$target/docs/pegasus/verify.md" "## Test Coverage / Manual Checks"
assert_file_contains "$target/docs/pegasus/verify.md" "## Final Verdict"
assert_file_contains "$target/docs/pegasus/verify.md" "Merge-not-overwrite instructions"
assert_file_contains "$target/.github/prompts/sdd-phases.prompt.md" "approved PRD and approved proposal"
assert_file_contains "$target/.github/prompts/sdd-phases.prompt.md" "Apply may record preliminary notes/evidence, but it does not replace the verify phase"
assert_file_contains "$target/.github/prompts/sdd-phases.prompt.md" "Do not make unrelated implementation changes during verify"

if grep -R -E 'review-risk|review-readability' "$target/.github" >/dev/null; then
  printf 'generated Copilot assets include excluded reviewer agents\n' >&2
  exit 1
fi

if grep -R -E 'Gentle AI|Engram' "$target" >/dev/null; then
  printf 'generated public files contain banned references\n' >&2
  exit 1
fi

if grep -R -E 'same as OpenCode|1:1 OpenCode|full OpenCode parity|exact OpenCode parity' "$target/.github" "$copilot_install_xdg/pegasus-ia/copilot" >/dev/null; then
  printf 'generated Copilot assets contain unsupported OpenCode/Copilot parity claims\n' >&2
  exit 1
fi

printf 'user content\n' > "$target/AGENTS.md"
printf 'custom apply progress\n' > "$target/docs/pegasus/apply-progress.md"
mkdir -p "$target/.github"
printf 'custom copilot instructions\n' > "$target/.github/copilot-instructions.md"
rm "$target/.github/agents/doc-designer.agent.md"
conflict_output="$($PYTHON_BIN "$CLI" --project-name sample-project --target-path "$target")"
case "$conflict_output" in
  *"Conflicts (skipped unless --force):"*"$target/AGENTS.md"*"Existing generated paths were preserved; skipped conflicting writes."*) ;;
  *) printf 'expected no-force conflicts to be reported and skipped\n' >&2; exit 1 ;;
esac
assert_file_contains "$target/AGENTS.md" "user content"
assert_file_contains "$target/docs/pegasus/apply-progress.md" "custom apply progress"
assert_file_contains "$target/.github/copilot-instructions.md" "custom copilot instructions"
[ -f "$target/.github/agents/doc-designer.agent.md" ] || { printf 'expected no-force run to create missing non-conflicting file\n' >&2; exit 1; }
"$PYTHON_BIN" - "$target/.pegasus-bootstrap-ia/manifest.json" <<'PY'
import json
import sys
from pathlib import Path

manifest = json.loads(Path(sys.argv[1]).read_text())
assert "AGENTS.md" in manifest["install"]["skipped_conflicts"]
assert ".github/copilot-instructions.md" in manifest["install"]["skipped_conflicts"]
paths = {record["path"] for record in manifest["install"]["files"]}
assert ".github/agents/doc-designer.agent.md" in paths
PY

force_output="$($PYTHON_BIN "$CLI" --project-name sample-project --target-path "$target" --force)"
case "$force_output" in
  *"Overwrites (--force):"*"$target/.github/copilot-instructions.md"*"$target/AGENTS.md"*) ;;
  *) printf 'expected force output to list overwritten harness files\n' >&2; exit 1 ;;
esac
assert_file_contains "$target/AGENTS.md" "sample-project"
assert_file_contains "$target/docs/pegasus/apply-progress.md" "Current In-Progress Work"
[ ! -e "$target/docs/pegasus/memory" ] || { printf 'force run should not create docs/pegasus/memory\n' >&2; exit 1; }
assert_no_banned_markdown_memory_persistence_refs "$target"
[ ! -e "$target/.git" ] || { printf 'bootstrap created git metadata\n' >&2; exit 1; }

sync_target="$TMP/sync-target"
printf 'yes\n' | "$PYTHON_BIN" "$CLI" --project-name sync-project --target-path "$sync_target" >/dev/null
printf 'custom prd\n' > "$sync_target/docs/pegasus/prd.md"
printf 'root proposal\n' > "$sync_target/proposal.md"
mkdir -p "$sync_target/docs/pegasus/changes/change-a" "$sync_target/.github/agents"
printf 'change spec\n' > "$sync_target/docs/pegasus/changes/change-a/spec.md"
printf 'user agent\n' > "$sync_target/.github/agents/user.agent.md"
printf 'old mcp config\n' > "$sync_target/.vscode/mcp.json"
printf 'user agents conflict\n' > "$sync_target/AGENTS.md"
printf 'obsolete managed\n' > "$sync_target/.cursor/rules/obsolete.mdc"
"$PYTHON_BIN" - "$sync_target/.pegasus-bootstrap-ia/manifest.json" "$sync_target/.vscode/mcp.json" <<'PY'
import hashlib
import json
import sys
from pathlib import Path

manifest_path = Path(sys.argv[1])
mcp_path = Path(sys.argv[2])
manifest = json.loads(manifest_path.read_text())
old_checksum = hashlib.sha256(mcp_path.read_text().rstrip("\n").encode()).hexdigest()
for section in (manifest["install"]["files"], manifest["ownership"]["files"]):
    for record in section:
        if record["path"] == ".vscode/mcp.json":
            record["checksum_sha256"] = old_checksum
obsolete = {
    "path": ".cursor/rules/obsolete.mdc",
    "ownership": "full-file",
    "managed_by": "pegasus-harness-bootstrap",
    "template_version": "1",
    "checksum_sha256": hashlib.sha256(b"obsolete managed").hexdigest(),
    "action": "created",
}
manifest["install"]["files"].append(obsolete)
manifest["ownership"]["files"].append(obsolete)
manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")
PY
sync_dry_output="$($PYTHON_BIN "$CLI" --target-path "$sync_target" --sync-workspace --dry-run)"
case "$sync_dry_output" in
  *"Pegasus workspace sync plan"*"Scope: current workspace only"*"Updates:"*"$sync_target/.vscode/mcp.json"*"Conflicts (skipped unless --overwrite-conflicts):"*"$sync_target/AGENTS.md"*"Obsolete managed files (report-only):"*"$sync_target/.cursor/rules/obsolete.mdc"*"Preserved user artifacts:"*"$sync_target/docs/pegasus/proposal.md"*"$sync_target/docs/pegasus/changes/**"*"Dry run only; no files were written."*) ;;
  *) printf 'expected workspace sync dry-run plan with updates, conflicts, obsolete files, and preserved artifacts\n' >&2; exit 1 ;;
esac
case "$sync_dry_output" in
  *"Preserved user artifacts:"*"$sync_target/proposal.md"*) printf 'preserved artifacts should use docs/pegasus paths, not root proposal.md\n' >&2; exit 1 ;;
  *) ;;
esac
sync_cwd_dry_output="$(cd "$sync_target" && "$PYTHON_BIN" "$CLI" --sync-workspace --dry-run)"
case "$sync_cwd_dry_output" in
  *"Pegasus workspace sync plan"*"Target: $sync_target"*"Manifest: $sync_target/.pegasus-bootstrap-ia/manifest.json"*"Dry run only; no files were written."*) ;;
  *) printf 'expected workspace sync dry-run from cwd without project name or target path\n' >&2; exit 1 ;;
esac
assert_file_contains "$sync_target/.vscode/mcp.json" 'old mcp config'
if sync_missing_manifest_output="$($PYTHON_BIN "$CLI" --target-path "$TMP/not-installed-sync" --sync-workspace --dry-run 2>&1)"; then
  printf 'sync should require a Pegasus workspace manifest\n' >&2
  exit 1
fi
case "$sync_missing_manifest_output" in
  *"workspace manifest not found: $TMP/not-installed-sync/.pegasus-bootstrap-ia/manifest.json"*) ;;
  *) printf 'expected sync missing manifest error with exact path\n' >&2; exit 1 ;;
esac
mkdir -p "$TMP/not-installed-sync-cwd"
if sync_cwd_missing_manifest_output="$(cd "$TMP/not-installed-sync-cwd" && "$PYTHON_BIN" "$CLI" --sync-workspace --dry-run 2>&1)"; then
  printf 'sync from cwd should require a Pegasus workspace manifest\n' >&2
  exit 1
fi
case "$sync_cwd_missing_manifest_output" in
  *"workspace manifest not found: $TMP/not-installed-sync-cwd/.pegasus-bootstrap-ia/manifest.json"*) ;;
  *) printf 'expected sync cwd missing manifest error with exact path\n' >&2; exit 1 ;;
esac
sync_output="$($PYTHON_BIN "$CLI" --project-name sync-project --target-path "$sync_target" --sync-workspace)"
case "$sync_output" in
  *"Completed Pegasus workspace sync."*"Updated: $sync_target/.vscode/mcp.json"*"Backup created: $sync_target/.pegasus-bootstrap-ia/backups/"*"Conflicting Pegasus-managed files were preserved"*"Obsolete Pegasus-managed files were reported only; none were deleted."*) ;;
  *) printf 'expected workspace sync completion with backup, conflict skip, and obsolete report-only output\n' >&2; exit 1 ;;
esac
assert_file_contains "$sync_target/AGENTS.md" 'user agents conflict'
assert_file_contains "$sync_target/docs/pegasus/prd.md" 'custom prd'
assert_file_contains "$sync_target/proposal.md" 'root proposal'
assert_file_contains "$sync_target/docs/pegasus/changes/change-a/spec.md" 'change spec'
assert_file_contains "$sync_target/.github/agents/user.agent.md" 'user agent'
assert_file_contains "$sync_target/.cursor/rules/obsolete.mdc" 'obsolete managed'
"$PYTHON_BIN" - "$sync_target/.vscode/mcp.json" "$PEGASUS_MEMORY_MCP_ROOT" <<'PY'
import json
import sys
from pathlib import Path

config = json.loads(Path(sys.argv[1]).read_text())
assert config["servers"]["pegasus-memory-mcp"]["cwd"] == sys.argv[2]
PY
sync_backup_count=$(compgen -G "$sync_target/.pegasus-bootstrap-ia/backups/*/.vscode/mcp.json" | wc -l)
[ "$sync_backup_count" -ge 1 ] || { printf 'expected workspace sync backup for mcp.json\n' >&2; exit 1; }
sync_override_output="$($PYTHON_BIN "$CLI" --project-name sync-project --target-path "$sync_target" --sync-workspace --overwrite-conflicts)"
case "$sync_override_output" in
  *"Completed Pegasus workspace sync."*"Updated: $sync_target/AGENTS.md"*"Backup created: $sync_target/.pegasus-bootstrap-ia/backups/"*) ;;
  *) printf 'expected overwrite-conflicts sync to back up and update AGENTS.md\n' >&2; exit 1 ;;
esac
assert_file_contains "$sync_target/AGENTS.md" 'sync-project'
if ! grep -R -F 'user agents conflict' "$sync_target/.pegasus-bootstrap-ia/backups" >/dev/null; then
  printf 'expected overwrite-conflicts backup to preserve AGENTS.md user content\n' >&2
  exit 1
fi
"$PYTHON_BIN" - "$sync_target/.pegasus-bootstrap-ia/manifest.json" <<'PY'
import json
import sys
from pathlib import Path

manifest = json.loads(Path(sys.argv[1]).read_text())
text = json.dumps(manifest)
for forbidden in ("active_change", "activeChange", "memory_state", "memoryState", "recovery_state", "recoveryState"):
    assert forbidden not in text
assert "last_run_at" in manifest["update"]
assert "AGENTS.md" in manifest["update"]["overwrite_conflicts"]
PY

uninstall_target="$TMP/uninstall-target"
printf 'yes\n' | "$PYTHON_BIN" "$CLI" --project-name uninstall-project --target-path "$uninstall_target" >/dev/null
mkdir -p "$uninstall_target/docs/pegasus" "$uninstall_target/.github/agents"
printf 'user note\n' > "$uninstall_target/docs/pegasus/user-note.md"
printf 'user agent\n' > "$uninstall_target/.github/agents/user.agent.md"
uninstall_dry_output="$($PYTHON_BIN "$CLI" --project-name uninstall-project --target-path "$uninstall_target" --uninstall-workspace --dry-run)"
case "$uninstall_dry_output" in
  *"Pegasus uninstall plan"*"Workspace file removals:"*"$uninstall_target/.pegasus-bootstrap-ia/manifest.json"*"Dry run only; no files were removed."*) ;;
  *) printf 'expected workspace uninstall dry-run plan\n' >&2; exit 1 ;;
esac
[ -f "$uninstall_target/AGENTS.md" ] || { printf 'workspace uninstall dry-run removed AGENTS.md\n' >&2; exit 1; }
[ -f "$uninstall_target/.pegasus-bootstrap-ia/manifest.json" ] || { printf 'workspace uninstall dry-run removed manifest\n' >&2; exit 1; }
uninstall_output="$($PYTHON_BIN "$CLI" --project-name uninstall-project --target-path "$uninstall_target" --uninstall-workspace)"
case "$uninstall_output" in
  *"Completed Pegasus workspace uninstall."*"Preserved non-empty directory:"*) ;;
  *) printf 'expected workspace uninstall completion and non-empty directory preservation\n' >&2; exit 1 ;;
esac
[ ! -e "$uninstall_target/AGENTS.md" ] || { printf 'workspace uninstall preserved managed AGENTS.md\n' >&2; exit 1; }
[ ! -e "$uninstall_target/.github/copilot-instructions.md" ] || { printf 'workspace uninstall preserved managed Copilot instructions\n' >&2; exit 1; }
[ ! -e "$uninstall_target/.pegasus-bootstrap-ia/manifest.json" ] || { printf 'workspace uninstall preserved manifest\n' >&2; exit 1; }
[ -f "$uninstall_target/docs/pegasus/user-note.md" ] || { printf 'workspace uninstall removed user docs file\n' >&2; exit 1; }
[ -f "$uninstall_target/.github/agents/user.agent.md" ] || { printf 'workspace uninstall removed user agent file\n' >&2; exit 1; }

uninstall_global_home="$TMP/uninstall-global-home"
uninstall_global_xdg="$TMP/uninstall-global-xdg"
uninstall_global_target="$TMP/uninstall-global-target"
mkdir -p "$uninstall_global_home" "$uninstall_global_xdg"
printf 'yes\n' | HOME="$uninstall_global_home" XDG_CONFIG_HOME="$uninstall_global_xdg" "$PYTHON_BIN" "$CLI" --project-name uninstall-global --target-path "$uninstall_global_target" --install-copilot-global >/dev/null
"$PYTHON_BIN" - "$uninstall_global_xdg" <<'PY'
import json
import sys
from pathlib import Path
xdg = Path(sys.argv[1])
settings_path = xdg / "Code/User/settings.json"
settings = json.loads(settings_path.read_text())
settings["editor.fontSize"] = 17
settings["chat.agentFilesLocations"]["/user/agents"] = True
settings_path.write_text(json.dumps(settings, indent=2) + "\n")
(xdg / "pegasus-ia/copilot/agents/user.agent.md").write_text("user global agent\n")
PY
uninstall_global_dry_output="$(HOME="$uninstall_global_home" XDG_CONFIG_HOME="$uninstall_global_xdg" "$PYTHON_BIN" "$CLI" --project-name uninstall-global --target-path "$uninstall_global_target" --uninstall-copilot-global --dry-run)"
case "$uninstall_global_dry_output" in
  *"Global VS Code/Copilot uninstall (--uninstall-copilot-global):"*"Settings backup:"*"Asset removals:"*"Dry run only; no files were removed."*) ;;
  *) printf 'expected Copilot global uninstall dry-run plan\n' >&2; exit 1 ;;
esac
[ -f "$uninstall_global_xdg/pegasus-ia/copilot/agents/pegasus-global-orchestrator.agent.md" ] || { printf 'global uninstall dry-run removed managed asset\n' >&2; exit 1; }
uninstall_global_output="$(HOME="$uninstall_global_home" XDG_CONFIG_HOME="$uninstall_global_xdg" "$PYTHON_BIN" "$CLI" --project-name uninstall-global --target-path "$uninstall_global_target" --uninstall-copilot-global)"
case "$uninstall_global_output" in
  *"Completed Pegasus global VS Code/Copilot uninstall."*"Backup created: $uninstall_global_xdg/Code/User/settings.json."*".bak"*"Preserved non-empty global directory:"*) ;;
  *) printf 'expected Copilot global uninstall completion, backup, and non-empty directory preservation\n' >&2; exit 1 ;;
esac
[ ! -e "$uninstall_global_xdg/pegasus-ia/copilot/agents/pegasus-global-orchestrator.agent.md" ] || { printf 'global uninstall preserved managed agent asset\n' >&2; exit 1; }
[ -f "$uninstall_global_xdg/pegasus-ia/copilot/agents/user.agent.md" ] || { printf 'global uninstall removed user global asset\n' >&2; exit 1; }
global_uninstall_backup_count=$(compgen -G "$uninstall_global_xdg/Code/User/settings.json.*.bak" | wc -l)
[ "$global_uninstall_backup_count" -ge 1 ] || { printf 'expected global uninstall settings backup\n' >&2; exit 1; }
"$PYTHON_BIN" - "$uninstall_global_xdg" <<'PY'
import json
import sys
from pathlib import Path
xdg = Path(sys.argv[1])
settings = json.loads((xdg / "Code/User/settings.json").read_text())
text = json.dumps(settings)
assert "pegasus-ia/copilot" not in text
assert settings["editor.fontSize"] == 17
assert settings["chat.agentFilesLocations"]["/user/agents"] is True
PY

invalid_uninstall_home="$TMP/invalid-uninstall-home"
invalid_uninstall_xdg="$TMP/invalid-uninstall-xdg"
invalid_uninstall_target="$TMP/invalid-uninstall-target"
mkdir -p "$invalid_uninstall_home" "$invalid_uninstall_xdg/Code/User" "$invalid_uninstall_xdg/pegasus-ia/copilot/agents"
printf '{ invalid json\n' > "$invalid_uninstall_xdg/Code/User/settings.json"
printf '<!-- PEGASUS-COPILOT-GLOBAL -->\nmanaged\n' > "$invalid_uninstall_xdg/pegasus-ia/copilot/agents/pegasus-global-orchestrator.agent.md"
if invalid_uninstall_output="$(HOME="$invalid_uninstall_home" XDG_CONFIG_HOME="$invalid_uninstall_xdg" "$PYTHON_BIN" "$CLI" --project-name invalid-uninstall --target-path "$invalid_uninstall_target" --uninstall-copilot-global 2>&1)"; then
  printf 'expected invalid settings JSON failure during global uninstall\n' >&2
  exit 1
fi
case "$invalid_uninstall_output" in
  *"invalid VS Code settings JSON"*) ;;
  *) printf 'expected clear invalid settings JSON error during global uninstall\n' >&2; exit 1 ;;
esac
assert_file_contains "$invalid_uninstall_xdg/Code/User/settings.json" '{ invalid json'
[ -f "$invalid_uninstall_xdg/pegasus-ia/copilot/agents/pegasus-global-orchestrator.agent.md" ] || { printf 'invalid global uninstall removed managed asset\n' >&2; exit 1; }
if compgen -G "$invalid_uninstall_xdg/Code/User/settings.json.*.bak" >/dev/null; then
  printf 'invalid global uninstall should not create backup\n' >&2
  exit 1
fi

global_home="$TMP/global-home"
global_xdg="$TMP/global-xdg"
global_dry_target="$TMP/global-dry-target"
mkdir -p "$global_home" "$global_xdg"
global_dry_output="$(HOME="$global_home" XDG_CONFIG_HOME="$global_xdg" "$PYTHON_BIN" "$CLI" --project-name global-dry --target-path "$global_dry_target" --install-cursor-global --dry-run)"
case "$global_dry_output" in
  *"Legacy global Cursor rules (--install-cursor-global):"*"$global_xdg/Cursor/User/rules"*"pegasus-global.mdc"*) ;;
  *) printf 'expected global dry-run output to list intended global operations\n' >&2; exit 1 ;;
esac
[ ! -e "$global_dry_target" ] || { printf 'global dry-run wrote target files\n' >&2; exit 1; }
[ ! -e "$global_xdg/Cursor" ] || { printf 'global dry-run wrote Cursor config\n' >&2; exit 1; }

global_target="$TMP/global-target"
global_output="$(printf 'yes\n' | HOME="$global_home" XDG_CONFIG_HOME="$global_xdg" "$PYTHON_BIN" "$CLI" --project-name global-project --target-path "$global_target" --install-cursor-global)"
global_rule="$global_xdg/Cursor/User/rules/pegasus-global.mdc"
[ -f "$global_rule" ] || { printf 'expected global Cursor rule to be written\n' >&2; exit 1; }
assert_file_contains "$global_rule" "PEGASUS-CURSOR-GLOBAL"
assert_file_contains "$global_rule" "Legacy Pegasus IA Global Cursor Guidance"
case "$global_output" in
  *"Updated legacy global Cursor rules: $global_xdg/Cursor/User/rules"*) ;;
  *) printf 'expected global install output to report updated global path\n' >&2; exit 1 ;;
esac

printf 'user global content\n' > "$global_rule"
global_update_output="$(HOME="$global_home" XDG_CONFIG_HOME="$global_xdg" "$PYTHON_BIN" "$CLI" --project-name global-project --target-path "$global_target" --install-cursor-global --force)"
case "$global_update_output" in
  *"Backup created: "*"pegasus-global.mdc."*".bak"*) ;;
  *) printf 'expected global update output to report backup path\n' >&2; exit 1 ;;
esac
backup_count=$(compgen -G "$global_xdg/Cursor/User/rules/pegasus-global.mdc.*.bak" | wc -l)
[ "$backup_count" -ge 1 ] || { printf 'expected global backup file\n' >&2; exit 1; }
if ! compgen -G "$global_xdg/Cursor/User/rules/pegasus-global.mdc.*.bak" >/dev/null; then
  printf 'expected global backup glob to match\n' >&2
  exit 1
fi
assert_file_contains "$(compgen -G "$global_xdg/Cursor/User/rules/pegasus-global.mdc.*.bak" | sort | tail -n 1)" "user global content"

legacy_home="$TMP/legacy-home"
legacy_xdg="$TMP/legacy-xdg"
legacy_target="$TMP/legacy-target"
mkdir -p "$legacy_home/.cursor/rules" "$legacy_xdg"
legacy_output="$(printf 'yes\n' | HOME="$legacy_home" XDG_CONFIG_HOME="$legacy_xdg" "$PYTHON_BIN" "$CLI" --project-name legacy-project --target-path "$legacy_target" --install-cursor-global)"
[ -f "$legacy_home/.cursor/rules/pegasus-global.mdc" ] || { printf 'expected legacy Cursor rules path to be preferred when it exists\n' >&2; exit 1; }
case "$legacy_output" in
  *"Existing legacy Cursor rules path detected and preferred"*) ;;
  *) printf 'expected legacy path note in output\n' >&2; exit 1 ;;
esac

if "$PYTHON_BIN" "$CLI" --project-name '../bad' --target-path "$TMP/bad" >/dev/null 2>&1; then
  printf 'expected invalid project-name failure\n' >&2
  exit 1
fi

printf 'Smoke tests passed.\n'
