#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI="$ROOT/bin/pegasus-harness-bootstrap"
PYTHON_BIN="${PYTHON_BIN:-python3}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

assert_file_contains() {
  local file="$1"
  local text="$2"
  grep -Fq "$text" "$file" || {
    printf 'Expected %s to contain %s\n' "$file" "$text" >&2
    exit 1
  }
}

expected_files=(
  "AGENTS.md"
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
  "docs/pegasus/prd.md"
  "docs/pegasus/proposal.md"
  "docs/pegasus/spec.md"
  "docs/pegasus/design.md"
  "docs/pegasus/tasks.md"
  "docs/pegasus/verify.md"
  "docs/pegasus/memory/context.md"
  "docs/pegasus/memory/decisions.md"
  "docs/pegasus/memory/tasks-log.md"
  "docs/pegasus/memory/handoff.md"
  "docs/pegasus/memory/learnings.md"
)

chmod +x "$CLI"

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
  *"Open the target workspace in Cursor"*) printf 'default dry-run should not present Cursor as the primary next step\n' >&2; exit 1 ;;
  *) ;;
esac

dry_target="$TMP/dry-run-project"
"$PYTHON_BIN" "$CLI" --project-name dry-run-project --target-path "$dry_target" --dry-run >/dev/null
[ ! -e "$dry_target" ] || { printf 'dry-run wrote files\n' >&2; exit 1; }

default_home="$TMP/default-home"
default_xdg="$TMP/default-xdg"
default_target="$TMP/default-no-global"
mkdir -p "$default_home" "$default_xdg"
default_run_output="$(HOME="$default_home" XDG_CONFIG_HOME="$default_xdg" "$PYTHON_BIN" "$CLI" --project-name default-no-global --target-path "$default_target")"
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
copilot_install_output="$(HOME="$copilot_install_home" XDG_CONFIG_HOME="$copilot_install_xdg" "$PYTHON_BIN" "$CLI" --project-name copilot-install --target-path "$copilot_install_target" --install-copilot-global)"
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
HOME="$copilot_insiders_home" XDG_CONFIG_HOME="$copilot_insiders_xdg" "$PYTHON_BIN" "$CLI" --project-name copilot-insiders --target-path "$copilot_insiders_target" --install-copilot-global --vscode-target insiders >/dev/null
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
merge_output="$(HOME="$merge_home" XDG_CONFIG_HOME="$merge_xdg" "$PYTHON_BIN" "$CLI" --project-name copilot-merge --target-path "$merge_target" --install-copilot-global)"
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
"$PYTHON_BIN" "$CLI" --project-name sample-project --target-path "$target" >/dev/null
for file in "${expected_files[@]}"; do
  [ -f "$target/$file" ] || { printf 'expected generated file %s\n' "$file" >&2; exit 1; }
done
assert_file_contains "$target/AGENTS.md" "sample-project"
assert_file_contains "$target/AGENTS.md" "$target"
assert_file_contains "$target/AGENTS.md" ".github/agents/pegasus-orchestrator.agent.md"
assert_file_contains "$target/.github/copilot-instructions.md" "Primary entry point"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "name: pegasus-orchestrator"
assert_file_contains "$target/.github/agents/sdd-apply.agent.md" "user-invocable: false"
assert_file_contains "$target/.cursor/rules/pegasus-memory.mdc" "context compaction"
assert_file_contains "$target/.cursor/rules/pegasus-workflow.mdc" "secondary legacy Cursor compatibility guidance"
assert_file_contains "$target/docs/pegasus/memory/context.md" "Read this file at the start"
assert_file_contains "$target/docs/pegasus/memory/context.md" 'VS Code/Copilot assets under `.github/`'

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
printf 'custom decisions\n' > "$target/docs/pegasus/memory/decisions.md"
mkdir -p "$target/.github"
printf 'custom copilot instructions\n' > "$target/.github/copilot-instructions.md"
if "$PYTHON_BIN" "$CLI" --project-name sample-project --target-path "$target" >/dev/null 2>&1; then
  printf 'expected conflict failure\n' >&2
  exit 1
fi
assert_file_contains "$target/AGENTS.md" "user content"
assert_file_contains "$target/docs/pegasus/memory/decisions.md" "custom decisions"
assert_file_contains "$target/.github/copilot-instructions.md" "custom copilot instructions"

force_output="$($PYTHON_BIN "$CLI" --project-name sample-project --target-path "$target" --force)"
case "$force_output" in
  *"Overwrites (--force):"*"$target/.github/copilot-instructions.md"*"$target/AGENTS.md"*) ;;
  *) printf 'expected force output to list overwritten harness files\n' >&2; exit 1 ;;
esac
assert_file_contains "$target/AGENTS.md" "sample-project"
assert_file_contains "$target/docs/pegasus/memory/decisions.md" "Decision Log"
[ ! -e "$target/.git" ] || { printf 'bootstrap created git metadata\n' >&2; exit 1; }

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
global_output="$(HOME="$global_home" XDG_CONFIG_HOME="$global_xdg" "$PYTHON_BIN" "$CLI" --project-name global-project --target-path "$global_target" --install-cursor-global)"
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
legacy_output="$(HOME="$legacy_home" XDG_CONFIG_HOME="$legacy_xdg" "$PYTHON_BIN" "$CLI" --project-name legacy-project --target-path "$legacy_target" --install-cursor-global)"
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
