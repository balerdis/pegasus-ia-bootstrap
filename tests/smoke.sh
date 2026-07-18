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
  ".github/references/shared/authority.md"
  ".github/references/shared/phase-common.md"
  ".github/references/shared/delegation-ownership.md"
  ".github/references/shared/persistence.md"
  ".github/references/shared/result-envelope.md"
  ".github/references/shared/status-readiness.md"
  ".github/references/shared/skill-resolution.md"
  ".github/references/phases/apply.md"
  ".github/references/phases/verify.md"
  ".github/references/results/apply-result-v1.md"
  ".github/references/results/verify-result-v1.md"
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

assert_wheel_reference_paths() {
  local wheel_dir="$TMP/wheel-dist"
  mkdir -p "$wheel_dir"
  "$VENV/bin/python" -m pip wheel --no-deps --wheel-dir "$wheel_dir" "$ROOT" >/dev/null
  "$VENV/bin/python" - "$wheel_dir" <<'PY'
from pathlib import Path
import sys
from zipfile import ZipFile

wheel = next(Path(sys.argv[1]).glob("*.whl"))
prefix = "pegasus_ia_bootstrap-0.6.9.data/data/share/pegasus-ia-bootstrap/templates/harness/.github/references/"
expected = {
    prefix + "shared/authority.md",
    prefix + "shared/phase-common.md",
    prefix + "shared/delegation-ownership.md",
    prefix + "shared/persistence.md",
    prefix + "shared/result-envelope.md",
    prefix + "shared/status-readiness.md",
    prefix + "shared/skill-resolution.md",
    prefix + "phases/apply.md",
    prefix + "phases/verify.md",
    prefix + "results/apply-result-v1.md",
    prefix + "results/verify-result-v1.md",
}
with ZipFile(wheel) as archive:
    actual = {name for name in archive.namelist() if name.startswith(prefix)}
assert actual == expected, (actual, expected)
PY
}

assert_wheel_reference_paths
if [ "${1:-}" = "wheel" ]; then
  exit 0
fi

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
version_output="$($PYTHON_BIN "$CLI" --version)"
case "$version_output" in
  "Pegasus Harness Bootstrap 0.6.9") ;;
  *) printf 'expected clear Pegasus product version output\n' >&2; exit 1 ;;
esac
assert_file_contains "$ROOT/pyproject.toml" 'version = "0.6.9"'
assert_file_contains "$ROOT/pegasus_harness_bootstrap/__init__.py" '__version__ = "0.6.9"'
assert_file_contains "$ROOT/README.md" '# Pegasus Harness Bootstrap 0.6.9'
assert_file_contains "$ROOT/README.md" 'La conversación con el usuario, este README y los mensajes públicos localizados pueden estar en español.'
assert_file_contains "$ROOT/README.md" 'los prompts, las instrucciones, la comunicación interna entre agentes, la prosa descriptiva persistente de Pegasus Memory y los artefactos generados usan inglés de forma predeterminada.'
assert_file_contains "$ROOT/README.md" 'El idioma de un artefacto generado cambia únicamente cuando el usuario indica de manera explícita el idioma para ese artefacto'
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
  *"--uninstall"*"--reset-memory-project"*"--purge-memory"*"--memory-cli-command"*) ;;
  *) printf 'expected help output to include workspace uninstall and memory cleanup flags\n' >&2; exit 1 ;;
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
    *"Installed CLI version: 0.6.9"*"Source template version: 0.6.9"*) ;;
  *) printf 'expected bootstrap plan version evidence\n' >&2; exit 1 ;;
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
apply_agent="$target/.github/agents/sdd-apply.agent.md"
references="$target/.github/references"
apply_reference="$references/phases/apply.md"
verify_agent="$target/.github/agents/sdd-verify.agent.md"
verify_reference="$references/phases/verify.md"
persistence_reference="$references/shared/persistence.md"
assert_file_contains "$apply_agent" 'exactly one authorized task-slice identity'
assert_file_contains "$apply_agent" 'If the workload forecast requires a decision'
assert_file_contains "$apply_agent" '.github/references/shared/authority.md'
assert_file_contains "$apply_agent" '.github/references/shared/skill-resolution.md'
assert_file_contains "$apply_agent" '.github/references/phases/apply.md'
assert_file_contains "$apply_agent" '.github/references/results/apply-result-v1.md'
assert_file_contains "$apply_agent" 'immediately return `blocked-missing-reference`'
assert_file_contains "$apply_agent" 'Do not search for, inspect, or use alternate, renamed, backup, neighboring, or similarly named copies.'
assert_file_contains "$apply_agent" 'current macro > phase reference > shared reference > workspace default > global fallback'
assert_file_contains "$apply_agent" 'PEGASUS_APPLY_RESULT_V1'
assert_file_contains "$apply_reference" 'MCP task progress and apply-progress before editing'
assert_file_contains "$apply_reference" 'preliminary apply evidence does not replace verification'
assert_file_contains "$apply_reference" 'Merge, rather than replace'
assert_file_contains "$apply_reference" '## Scope And Authority'
assert_file_contains "$verify_agent" 'exactly one change identity'
assert_file_contains "$verify_agent" 'exactly one implemented task-slice identity'
assert_file_contains "$verify_agent" 'exactly one evidence-scope identity'
assert_file_contains "$verify_agent" '.github/references/phases/verify.md'
assert_file_contains "$verify_agent" '.github/references/results/verify-result-v1.md'
assert_file_contains "$verify_agent" 'immediately return `blocked-missing-reference`'
assert_file_contains "$verify_agent" 'Do not search for, inspect, or use alternate, renamed, backup, neighboring, or similarly named copies.'
assert_file_contains "$verify_agent" 'current macro > phase reference > shared reference > workspace default > global fallback'
assert_file_contains "$verify_agent" 'PEGASUS_VERIFY_RESULT_V1'
assert_file_contains "$verify_reference" 'fresh context as an operational rule, not a runtime guarantee'
assert_file_contains "$verify_reference" 'Compare implementation against PRD, proposal, spec requirements/scenarios, design constraints, tasks, and apply-progress'
assert_file_contains "$verify_reference" 'Do not make unrelated changes or edit implementation unless the user separately authorizes a later remediation run.'
if grep -R -Eq '^applyTo:' "$target/.github/references"; then
  printf 'references must remain manually loaded\n' >&2
  exit 1
fi
apply_body_lines=$(awk 'BEGIN { frontmatter=0; body=0 } /^---$/ { frontmatter++; next } frontmatter >= 2 { body++ } END { print body }' "$apply_agent")
[ "$apply_body_lines" -le 30 ] || { printf 'sdd-apply macro exceeds 30 body lines\n' >&2; exit 1; }
verify_body_lines=$(awk 'BEGIN { frontmatter=0; body=0 } /^---$/ { frontmatter++; next } frontmatter >= 2 { body++ } END { print body }' "$verify_agent")
[ "$verify_body_lines" -le 30 ] || { printf 'sdd-verify macro exceeds 30 body lines\n' >&2; exit 1; }
if grep -Eq '^## (Input contract|Required reads|Output contract|Stopping point|Forbidden scope|Merge/update rules|Phase-specific checklist)$' "$verify_agent"; then
  printf 'sdd-verify macro retains duplicated normative workflow body\n' >&2
  exit 1
fi
"$PYTHON_BIN" - "$ROOT" <<'PY'
from pathlib import Path
import sys
import tomllib

root = Path(sys.argv[1])
config = tomllib.loads((root / "pyproject.toml").read_text(encoding="utf-8"))
data_files = config["tool"]["setuptools"]["data-files"]
expected = {
    "shared/authority.md", "shared/phase-common.md", "shared/delegation-ownership.md",
    "shared/persistence.md", "shared/result-envelope.md", "shared/status-readiness.md",
    "shared/skill-resolution.md", "phases/apply.md", "phases/verify.md",
    "results/apply-result-v1.md", "results/verify-result-v1.md",
}
base = root / "templates/harness/.github/references"
actual = set()
destination_root = "share/pegasus-ia-bootstrap/templates/harness/.github/references/"
for destination, patterns in data_files.items():
    if not destination.startswith(destination_root):
        continue
    relative_destination = destination.removeprefix(destination_root)
    for pattern in patterns:
        actual.update(
            f"{relative_destination}/{path.name}" for path in root.glob(pattern)
        )
assert actual == expected, (actual, expected)
PY
"$PYTHON_BIN" - "$ROOT/templates/harness" "$target" <<'PY'
from pathlib import Path
import sys

canonical, generated = map(Path, sys.argv[1:])
references = sorted((canonical / ".github/references").rglob("*.md"))
for source_path in [canonical / ".github/agents/sdd-apply.agent.md", canonical / ".github/agents/sdd-verify.agent.md", *references]:
    relative = source_path.relative_to(canonical)
    source = source_path.read_text(encoding="utf-8").rstrip("\n")
    installed = (generated / relative).read_text(encoding="utf-8").splitlines()
    assert "\n".join(installed[1:-1]) == source, str(relative)
PY
"$PYTHON_BIN" - "$ROOT/templates/harness" <<'PY'
from pathlib import Path
import re
import sys

root = Path(sys.argv[1])
apply_agent = (root / ".github/agents/sdd-apply.agent.md").read_text(encoding="utf-8")
verify_agent = (root / ".github/agents/sdd-verify.agent.md").read_text(encoding="utf-8")
reference_root = root / ".github/references"
expected = [
    "shared/authority.md", "shared/phase-common.md", "shared/delegation-ownership.md",
    "shared/skill-resolution.md", "shared/persistence.md", "phases/apply.md",
    "phases/verify.md", "shared/status-readiness.md", "shared/result-envelope.md",
    "results/apply-result-v1.md", "results/verify-result-v1.md",
]
actual_files = {path.relative_to(reference_root).as_posix() for path in reference_root.rglob("*.md")}
assert actual_files == set(expected), (actual_files, set(expected))
assert not (reference_root / "pegasus-shared-authority.md").exists()
assert not (reference_root / "sdd-apply-phase.md").exists()

apply_expected = [path for path in expected if path not in {"phases/verify.md", "results/verify-result-v1.md"}]
verify_expected = [path for path in expected if path not in {"phases/apply.md", "results/apply-result-v1.md"}]
for agent, paths in ((apply_agent, apply_expected), (verify_agent, verify_expected)):
    positions = [agent.index(f".github/references/{path}") for path in paths]
    assert positions == sorted(positions), positions
for literal in (
    "exactly one authorized task-slice identity", "current resolved strategy",
    "Every exact path above is required", "blocked-missing-reference",
    "alternate, renamed, backup, neighboring, or similarly named copies",
    "current macro > phase reference > shared reference > workspace default > global fallback",
    "same-level conflict", "PEGASUS_APPLY_RESULT_V1", "no implementation-success claim",
):
    assert literal in apply_agent, literal
for literal in (
    "exactly one change identity", "exactly one implemented task-slice identity",
    "exactly one evidence-scope identity", "Every exact path above is required",
    "blocked-missing-reference", "alternate, renamed, backup, neighboring, or similarly named copies",
    "current macro > phase reference > shared reference > workspace default > global fallback",
    "same-level conflict", "PEGASUS_VERIFY_RESULT_V1", "no verification-success claim",
):
    assert literal in verify_agent, literal

edges = {path: set() for path in expected}
for relative in expected:
    text = (reference_root / relative).read_text(encoding="utf-8")
    assert not re.search(r"^applyTo:", text, re.MULTILINE), relative
    for target in re.findall(r"\.github/references/([^`\s]+\.md)", text):
        assert target in edges, (relative, target)
        edges[relative].add(target)

visiting, visited = set(), set()
def visit(node):
    assert node not in visiting, f"reference cycle at {node}"
    if node in visited:
        return
    visiting.add(node)
    for child in edges[node]:
        visit(child)
    visiting.remove(node)
    visited.add(node)
for node in edges:
    visit(node)
assert visited == set(expected)

owners = {
    "shared/authority.md": "instruction precedence and conflict handling only",
    "shared/phase-common.md": "behavior common to specialist phase execution",
    "shared/delegation-ownership.md": "specialist execution and ownership boundaries",
    "shared/persistence.md": "generic Pegasus Memory recovery and persistence behavior",
    "shared/result-envelope.md": "invariant specialist result-envelope semantics only",
    "shared/status-readiness.md": "generic status selection and readiness claims",
    "shared/skill-resolution.md": "exact skill paths supplied in its invocation context",
    "phases/apply.md": "detailed `sdd-apply` workflow",
    "phases/verify.md": "only the detailed `sdd-verify` workflow",
    "results/apply-result-v1.md": "Apply v1 result schema",
    "results/verify-result-v1.md": "only the Verify v1 result schema",
}
texts = {path: (reference_root / path).read_text(encoding="utf-8") for path in owners}
for relative, phrase in owners.items():
    assert phrase in texts[relative], (relative, phrase)
    for other in set(owners) - {relative}:
        assert phrase not in texts[other], (relative, other, phrase)
PY
assert_file_contains "$target/.github/agents/doc-designer.agent.md" "PRD and discovery contract"
assert_file_contains "$target/.github/agents/doc-designer.agent.md" "Do not write technical design"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "Proposal-only contract"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "Stop before spec, design, and tasks"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "Conversational approval does not override a PRD that still says Draft"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "record_task_progress"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "record_handoff"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "Every product claim, scope item, user, rule"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "MCP persistence summary:"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "Proposal persistence: file-only"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" '<!-- pegasus-harness:start path=docs/pegasus/changes/<change-id>/proposal.md ownership=full-file -->'
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" '<!-- pegasus-harness:end path=docs/pegasus/changes/<change-id>/proposal.md -->'
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "Preserve existing Pegasus managed markers exactly and edit only the content between them"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "the exact first line MUST be"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "the exact final line MUST be"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "before any MCP persistence call"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "repair the artifact by preserving or restoring both markers"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "Do not make any MCP persistence call or report success until marker validation passes"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "Preserve the target artifact language's standard orthography and diacritics"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" '`única`, `técnicas`, and `implementación`'
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "never conversational persona wording"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "only default product-content source"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "Do not search, read, inspect, or reuse neighboring or unrelated change artifacts"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "isolated changes must not read neighboring proposals"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "current PRD, active MCP context, or a direct user instruction explicitly declares its dependency or relation"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "Related Change Traceability entry"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "it was not used as an implicit scope source"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "Never implicitly inherit scope, decisions, assumptions, wording, or style"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "exactly one terminal disposition"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" 'An `ambiguous` MCP response never resolves a material gap'
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "For a blocking gap, ask one concise question and stop before writing or finalizing the proposal"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" 'dedicated `Open Decisions / Material Gaps` section'
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "reconcile every material gap before marker validation and before any MCP persistence call"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" 'MUST NOT say `no open questions`, `no open decisions`, or equivalent'
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "ensure_project: <succeeded|not needed|failed: reason>"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "ensure_change: <succeeded|not needed|failed: reason>"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "record_artifact: <succeeded|not needed|failed: reason>"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "record_observation: <succeeded|not needed|failed: reason>"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "record_task_progress: <succeeded|not needed|failed: reason>"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "record_handoff: <succeeded|not needed|failed: reason>"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "including when MCP is unavailable"
assert_file_contains "$target/docs/pegasus/prd.md" "Current Situation / Gap"
assert_file_contains "$target/docs/pegasus/prd.md" "Approval Owner"
assert_file_contains "$target/docs/pegasus/proposal.md" "PRD Source / Status"
assert_file_contains "$target/docs/pegasus/proposal.md" "Explicit Exclusions"
assert_file_contains "$target/docs/pegasus/proposal.md" "## PRD Traceability"
assert_file_contains "$target/docs/pegasus/proposal.md" "Record only assumptions explicitly stated in the approved PRD"
assert_file_contains "$target/docs/pegasus/proposal.md" "## Related Change Traceability"
assert_file_contains "$target/docs/pegasus/proposal.md" "The current change PRD is the only product-content source"
assert_file_contains "$target/docs/pegasus/proposal.md" "Consult another change only when the current PRD, active MCP context, or direct user instruction explicitly declares a dependency/relation"
assert_file_contains "$target/docs/pegasus/proposal.md" "Not an Implicit Scope Source"
assert_file_contains "$target/docs/pegasus/proposal.md" "were not inherited implicitly"
assert_file_contains "$target/docs/pegasus/proposal.md" "## Open Decisions / Material Gaps"
assert_file_contains "$target/docs/pegasus/proposal.md" "Resolution Evidence / Source"
assert_file_contains "$target/docs/pegasus/proposal.md" "Needed-by Gate"
assert_file_contains "$target/docs/pegasus/proposal.md" "An ambiguous MCP response never resolves a material gap"
assert_file_contains "$target/docs/pegasus/proposal.md" "For a blocking gap, ask one concise question and stop before writing or finalizing the proposal"
assert_file_contains "$target/docs/pegasus/proposal.md" "after an explicit reliable answer resolves it, record the resolved evidence in this section before proceeding"
assert_file_contains "$target/docs/pegasus/proposal.md" "No gaps identified"
if grep -Fq '| None identified, or TBD | TBD | TBD | TBD | TBD | TBD |' "$target/docs/pegasus/proposal.md"; then
  printf 'proposal template contains a contradictory unresolved TBD material-gap row\n' >&2
  exit 1
fi
assert_file_contains "$target/docs/pegasus/apply-progress.md" "Current In-Progress Work"
assert_file_contains "$target/docs/pegasus/apply-progress.md" "Merge updates into the existing useful history"
assert_file_contains "$target/.github/references/phases/verify.md" "Treat fresh context as an operational rule, not a runtime guarantee."
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "Launch deduplication"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "MCP persistence summary:"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "ensure_project: <succeeded|not needed|failed: reason>"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "Preserve existing Pegasus managed markers exactly and edit only content between them"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "reread and validate those exact first/last marker lines before any MCP persistence call"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "if validation fails, repair the markers, reread, and validate again before persistence"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "Preserve target-language standard orthography and diacritics"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "The current change PRD is the only default product-content source"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "Do not search, read, inspect, or reuse neighboring or unrelated change artifacts"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "When that happens, disclose in Related Change Traceability"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "that it was not an implicit scope source"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "A blocking material gap requires one concise user question and a stop before proposal writing/finalization"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "An ambiguous MCP response never resolves a material gap"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "Require reconciliation of every material gap before marker validation and MCP persistence"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "without claiming no open questions while any unresolved gap remains"
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
assert_file_contains "$target/AGENTS.md" "Pegasus Memory operational persistence"
assert_file_contains "$target/AGENTS.md" "Agent-consumed artifacts default to English unless the user explicitly names another language for the artifact"
assert_file_contains "$target/.github/instructions/pegasus-sdd-boundaries.instructions.md" "Generate every agent-consumed artifact in English by default"
assert_file_contains "$target/.github/instructions/pegasus-sdd-boundaries.instructions.md" "Never infer artifact language from chat, persona, dominant source language, or prior artifacts"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "Write all durable Pegasus Memory descriptive prose in English"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "Artifact-language overrides never override memory prose language"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" 'record `Artifact language: <language>`'
assert_file_contains "$target/.github/copilot-instructions.md" "Chat, persona, dominant source language, and prior artifacts do not select artifact language"
assert_file_contains "$ROOT/openspec/config.yaml" "Artifact language: English by default"
assert_file_contains "$ROOT/openspec/config.yaml" "Memory language: durable Pegasus Memory descriptive prose is always English"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" "Agent artifact and durable memory language"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" "dominant source language, and prior artifact language MUST NOT implicitly select artifact language"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" "Durable Pegasus Memory descriptive prose MUST be English regardless of chat or artifact language"
"$PYTHON_BIN" - "$ROOT" <<'PY'
import sys
from pathlib import Path

root = Path(sys.argv[1])
sdd = (root / "templates/harness/.github/instructions/pegasus-sdd-boundaries.instructions.md").read_text()
memory = (root / "templates/harness/.github/instructions/pegasus-memory.instructions.md").read_text()
copilot = (root / "templates/harness/.github/copilot-instructions.md").read_text()
spec = (root / "openspec/specs/pegasus-harness-bootstrap/spec.md").read_text()

for text in (sdd, copilot, spec):
    assert "dominant approved PRD/proposal language applies" not in text
    assert "otherwise use the dominant approved PRD/proposal language" not in text
assert "regardless of chat, persona, source, or artifact language" in memory
assert "Artifact-language overrides never override memory prose language" in memory
assert "Artifact language: <language>" in memory
assert "required public warnings" in memory
PY
assert_file_contains "$target/AGENTS.md" "pegasus-harness:start path=AGENTS.md ownership=marker-managed"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "pegasus-harness:start path=.github/agents/pegasus-orchestrator.agent.md ownership=full-file"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "call the \`pegasus-memory-mcp\` \`health\` tool before the first recovery attempt"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "call \`health\` before the first save"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "Natural-language PRD intent"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "quiero armar un PRD para esta idea"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "Before editing or finalizing any PRD, identify open product/business decisions."
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "do not silently decide product scope"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" 'Before invoking any git command, first check whether the workspace root contains a `.git` directory.'
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" 'If `.git` is absent, never attempt `git diff`, `git status`, `git log`, or any other git validation; do not try and fall back.'
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" 'include a small MCP persistence summary with one line each for `ensure_project`, `ensure_change`, `record_artifact`, and `record_observation`'
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" 'call `ensure_change` by default with only `project_id` and `change_id`'
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" 'never send `type` or both `kind` and `type`, even if equal'
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" 'Do not send nested `metadata`, arrays, decisions, questions/answers, or artifact summaries to `ensure_change`'
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "Tell the user the PRD file path (\`docs/pegasus/prd.md\`, \`docs/pegasus/changes/<change-id>/prd.md\`, or the full path when useful) and ask them to review it."
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "Wait for explicit user approval of the PRD before moving to proposal, spec, design, tasks, apply, or verify."
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "A conversational statement alone never overrides a PRD that still says Draft"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" 'save those details afterward with `record_observation` or `record_artifact`'
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "Do not implement code, create technical design, write tasks, or advance to proposal/spec/design/tasks/apply during PRD flow."
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "ensure_project"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "ensure_change"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "project_not_found"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "# Pegasus Memory operational persistence"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "Call its \`health\` tool before the first recovery or save attempt"
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
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" 'Use minimal compatible ensure payloads.'
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" 'By default, call `ensure_change({ project_id: <project-id>, change_id: <change-id> })`'
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" 'Never send `type`, and never send both `kind` and `type`, even with equal values'
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" 'Do not send nested `metadata`, arrays, product decisions, questions/answers, artifact summaries, or arbitrary extra fields to `ensure_change`'
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "project_not_found"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "foreign-key failures"
assert_file_contains "$target/.github/copilot-instructions.md" "call the \`pegasus-memory-mcp\` \`health\` tool before the first recovery attempt"
assert_file_contains "$target/.github/copilot-instructions.md" "call \`health\` before the first MCP save attempt"
assert_file_contains "$target/.github/copilot-instructions.md" "proactively save durable decisions, bugfixes, discoveries/gotchas"
assert_file_contains "$target/.github/copilot-instructions.md" "Keep consumer states distinct: \`not_found\`"
assert_file_contains "$target/.github/copilot-instructions.md" "Natural-language PRD intent is enough to start PRD discovery."
assert_file_contains "$target/.github/copilot-instructions.md" "never silently decide product scope"
assert_file_contains "$target/.github/copilot-instructions.md" 'include a small MCP persistence summary marking `ensure_project`, `ensure_change`, `record_artifact`, and `record_observation` as `succeeded`, `not needed`, or `failed: <reason>`'
assert_file_contains "$target/.github/copilot-instructions.md" 'using only `project_id` and `change_id` by default; add `key`, `title`, `status`, or `description` only when needed, and use `kind` only if classification is needed'
assert_file_contains "$target/.github/copilot-instructions.md" 'Never send `type` or both `kind` and `type`, even if equal'
assert_file_contains "$target/.github/copilot-instructions.md" 'before any git command first check for `.git` and never run `git diff`, `git status`, or other git validation in non-git workspaces; do not try git first and fall back'
assert_file_contains "$target/.github/copilot-instructions.md" 'must not reset, delete, recreate, or overwrite the Pegasus Memory database'
assert_file_contains "$target/.github/copilot-instructions.md" "wait for explicit PRD approval before proposal/spec/design/tasks/apply, and do not implement code during PRD flow"
assert_file_contains "$target/.github/copilot-instructions.md" "Before proposal, inspect the referenced PRD file rather than relying on conversational approval."
assert_file_contains "$target/.github/copilot-instructions.md" "do not turn unstated details into preserved PRD assumptions"
assert_file_contains "$target/.github/copilot-instructions.md" "Proposal persistence: file-only"
assert_file_contains "$target/.github/copilot-instructions.md" "ensure_project"
assert_file_contains "$target/.github/copilot-instructions.md" "ensure_change"
assert_file_contains "$target/.github/copilot-instructions.md" "project_not_found"
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" "Natural-language product intent should trigger PRD discovery automatically."
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" "Before proposal drafting, inspect the referenced PRD artifact's Approval table/status."
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" "never call an unstated detail a preserved PRD assumption"
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" "MCP persistence summary:"
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" "The current change PRD is the only default product-content source"
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" "Do not search, read, inspect, or reuse neighboring or unrelated change artifacts"
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" "Consult another change only when the current PRD, active MCP context, or direct user instruction explicitly declares a dependency/relation"
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" "that it was not used as an implicit scope source"
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" "Reconcile every material gap before finalization"
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" "An ambiguous MCP response never resolves a material gap"
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" "for a blocking gap, ask one concise question and stop before writing/finalizing"
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" "The final response must summarize resolved and unresolved gaps"
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" "tell the user the PRD file path and ask them to review it"
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" "product decisions are open"
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" 'record_artifact`, and `record_observation` as `succeeded`, `not needed`, or `failed: <reason>`'
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" 'using only `project_id` and `change_id` by default; add `key`, `title`, `status`, or `description` only when needed, and use `kind` only if classification is needed'
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" 'Never send `type` or both `kind` and `type`, even if equal'
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" 'before any git command first check for `.git` and never run `git diff`, `git status`, or other git validation in non-git workspaces; do not try git first and fall back'
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" 'The only allowed database mutation is an explicit Pegasus Memory schema migration performed by Pegasus Memory itself'
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" 'must not reset, delete, recreate, or overwrite the Pegasus Memory database'
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" 'Clean test memory must be created as explicit test setup, never as a sync side effect.'
for memory_guided_agent in doc-designer sdd-proposal sdd-spec sdd-design sdd-tasks session-handoff memory-maintainer pegasus-orchestrator; do
  assert_file_contains "$target/.github/agents/$memory_guided_agent.agent.md" "pegasus-memory.instructions.md"
done
assert_file_contains "$persistence_reference" "pegasus-memory.instructions.md"
assert_file_contains "$target/.github/agents/doc-designer.agent.md" "PRD/product discoveries"
assert_file_contains "$target/.github/agents/sdd-proposal.agent.md" "proposal status, assumptions, scope decisions, risks"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "requirement decisions, scenario coverage, open questions"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "architecture decisions, tradeoffs, alternatives, risks"
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "task progress, blockers, review budget assessment"
assert_file_contains "$apply_reference" "current/completed work, changed files, preliminary commands/results"
assert_file_contains "$persistence_reference" "Merge durable observations, task progress, artifact references, blockers, evidence, and handoff state"
assert_file_contains "$verify_reference" "persist verification evidence, deviations, verdict, remediation needs"
assert_file_contains "$verify_reference" "Merge the verification entry"
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
assert manifest["template_version"] == "0.6.9"
assert manifest["uninstall"]["remove_only_managed"] is True
paths = {record["path"]: record for record in manifest["install"]["files"]}
assert "AGENTS.md" in paths
assert ".vscode/mcp.json" in paths
assert paths["AGENTS.md"]["ownership"] == "marker-managed"
assert paths[".vscode/mcp.json"]["ownership"] == "full-file"
assert paths[".github/agents/pegasus-orchestrator.agent.md"]["ownership"] == "full-file"
assert all(record["package_version"] == "0.6.9" for record in paths.values())
assert all(record["template_version"] == "0.6.9" for record in paths.values())
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

for agent in sdd-spec sdd-design sdd-tasks; do
  agent_file="$target/.github/agents/$agent.agent.md"
  assert_file_contains "$agent_file" "## Input contract"
  assert_file_contains "$agent_file" "## Required reads"
  assert_file_contains "$agent_file" "## Output contract"
  assert_file_contains "$agent_file" "## Stopping point"
  assert_file_contains "$agent_file" "## Forbidden scope"
  assert_file_contains "$agent_file" "## Phase-specific checklist"
done
for heading in "## Input Contract" "## Required Reads" "## Duplicate And Execution Rules" "## Progress Updates" "## Stop And Return"; do
  assert_file_contains "$apply_reference" "$heading"
done
for heading in "## Inputs And Fresh Reads" "## Verification Workflow" "## Updates And Status" "## Stop And Return"; do
  assert_file_contains "$verify_reference" "$heading"
done

assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "approved PRD and approved proposal"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" 'GIVEN` / `WHEN` / `THEN'
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "Do not design architecture"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "Conversational approval never overrides"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "approval table, status, or checkbox"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "only default product and requirements sources"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "Do not search, read, inspect, or reuse neighboring or unrelated change artifacts"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "Related Change Traceability"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "not used as an implicit scope source"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "Every normative requirement MUST trace"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "An ambiguous MCP response never resolves a material gap"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "owner, impact, next step, and needed-by gate"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "For a blocking gap, ask one concise question and stop before finalizing"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" '<!-- pegasus-harness:start path=docs/pegasus/changes/<change-id>/spec.md ownership=full-file -->'
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" '<!-- pegasus-harness:end path=docs/pegasus/changes/<change-id>/spec.md -->'
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "Before any Pegasus Memory persistence call, read the artifact back"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "repair the artifact, reread, and validate again"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "If repair and reread still fail validation, block Pegasus Memory persistence and success"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "Spec persistence: file-only — marker validation failed"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "Preserve target-language standard orthography and diacritics"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "an explicit user artifact-language request wins"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "otherwise use English. Chat, persona, approved-source language, and prior artifacts never infer an override"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "an explicit user artifact-language request wins"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "neutral, professional Spanish"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "with no persona slang"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "Keep headings, table labels, metadata labels, and body prose consistently in the selected language"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "Immutable managed markers, identifiers, RFC 2119 keywords when deliberately standardized, code, paths, and tool names may remain unchanged"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "canonical-template headings and labels are translated"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" '`Especificacion`, `aceptacion`, `version`, and `contractacion` are absent'
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" '`Especificación`, `aceptación`, `versión`, and `contratación`'
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "repair only the affected language blocks, reread the whole artifact, revalidate markers, and rerun the language gate"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "stop without Pegasus Memory persistence or a success claim"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "Spec persistence: file-only — language validation failed: <exact issues>"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "Artifact language: <selected language>"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "Language gate: <passed|blocked: exact unresolved issues>"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "structural metadata MUST use \`Creado:\` and \`Destino:\`"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "reject \`Created:\`, \`Target:\`, and every applicable default-English canonical heading or table label"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "standardized \`GIVEN\` / \`WHEN\` / \`THEN\`, contractually required canonical enum values such as \`Approved\` or \`Draft\`"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "Language gate: passed\` is forbidden while any prohibited English structural label remains"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "Spec persistence: file-only"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "Pegasus Memory persistence summary:"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "call or attempt \`record_task_progress\` before \`record_handoff\`"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "use status \`completed\` on the first attempt"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "supported status enum is exactly \`pending\`, \`in_progress\`, \`blocked\`, \`completed\`"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "ready for review\` / draft complete in its descriptive fields or notes"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "Do not return the final response until all six Pegasus Memory operations have a terminal status"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "never invent it for an omitted call"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "If \`record_artifact\` or \`record_observation\` fails"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "Spec persistence: file-only — <reason>"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "Pegasus Memory persistence incomplete/partial — <failed operation>: <reason>"
assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "MUST prevent claiming full durable completion or Pegasus Memory success"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "Other MCP servers may coexist"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "not substitutes for Pegasus Memory persistence"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "For spec closure"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "Pegasus Memory persistence summary:"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "complete task-progress payload records phase \`spec\`"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "Pegasus Memory persistence incomplete/partial — <failed operation>: <reason>"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "prevents a full durable-completion or Pegasus Memory-success claim"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "call or attempt \`record_task_progress\` for phase \`spec\` before \`record_handoff\`"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "truthful terminal statuses for all six operations"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "never invent \`succeeded\` for an omitted call"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "Pegasus Memory persistence incomplete/partial — <failed operation>: <reason>"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "forbids any full durable-completion or Pegasus Memory-success claim"
"$PYTHON_BIN" - "$target/.github/agents/sdd-spec.agent.md" <<'PY'
import sys
from pathlib import Path

text = Path(sys.argv[1]).read_text()
assert text.index("record_task_progress` before `record_handoff") < text.index("Do not return the final response until all six Pegasus Memory operations")
assert "MCP persistence summary:" not in text
payload = next(line for line in text.splitlines() if "The task-progress record MUST identify" in line)
for required in ("phase `spec`", "status `completed` on the first attempt", "spec artifact path", "ready for review` / draft complete", "open gaps/blockers", "next action `user review/approval`"):
    assert required in payload
assert "supported status enum is exactly `pending`, `in_progress`, `blocked`, `completed`" in text
assert "status `ready-for-review`" not in text
assert "status `completed-as-draft`" not in text
assert "Spec persistence: file-only — <reason>" in text
assert "Pegasus Memory persistence incomplete/partial — <failed operation>: <reason>" in text
assert "MUST prevent claiming full durable completion or Pegasus Memory success" in text
for operation in (
    "ensure_project: <succeeded|not needed|failed: reason>",
    "ensure_change: <succeeded|not needed|failed: reason>",
    "record_artifact: <succeeded|not needed|failed: reason>",
    "record_observation: <succeeded|not needed|failed: reason>",
    "record_task_progress: <succeeded|not needed|failed: reason>",
    "record_handoff: <succeeded|not needed|failed: reason>",
):
    assert operation in text
PY
"$PYTHON_BIN" - "$target/.github/agents/sdd-spec.agent.md" <<'PY'
import sys
from pathlib import Path

text = Path(sys.argv[1]).read_text()
assert text.index("After marker validation and before any Pegasus Memory persistence") < text.index("## Pegasus Memory closure contract")
assert text.index("repair only the affected language blocks") < text.index("If any issue remains, stop without Pegasus Memory persistence")
assert text.index("Artifact language: <selected language>") < text.index("Pegasus Memory persistence summary:")
PY
"$PYTHON_BIN" - "$target/.github/agents/sdd-spec.agent.md" "$target/docs/pegasus/spec.md" <<'PY'
import re
import sys
from pathlib import Path

guidance = Path(sys.argv[1]).read_text()
template = Path(sys.argv[2]).read_text()

# The canonical template remains English by default but supplies an explicit
# Spanish structural vocabulary for a Spanish artifact rendering.
for required in ("Created:", "Target:", "`Creado:`", "`Destino:`", "Required Spanish rendering"):
    assert required in template, required

# This models the required structural-only post-write scan. It catches labels,
# not permitted terms that merely happen to be English.
prohibited = re.compile(r"(?m)^(?:Created:|Target:|# Specification:|## Purpose$|## Source Status$|\| Source \|)")
bad_spanish_artifact = "# Especificación: demo\nCreated: hoy\nTarget: /tmp/demo\n"
allowed_exceptions = "\n".join((
    "- GIVEN an approved source",
    "- WHEN status is Approved",
    "- THEN keep `pegasus-memory-mcp` at `docs/pegasus/spec.md`",
    "Source section: `PRD Source / Status`",
    "Code: `ensure_change({ project_id: id })`",
))
assert prohibited.search(bad_spanish_artifact)
assert not prohibited.search(allowed_exceptions)

assert guidance.index("require `Creado:` and `Destino:`") < guidance.index("repair only the affected language blocks")
assert guidance.index("repair only the affected language blocks") < guidance.index("Language gate: passed` is forbidden")
assert guidance.index("Language gate: passed` is forbidden") < guidance.index("Pegasus Memory closure contract")
PY
"$PYTHON_BIN" - "$target" <<'PY'
import sys
from pathlib import Path

target = Path(sys.argv[1])
payload_guidance = (
    target / ".github/agents/sdd-spec.agent.md",
    target / ".github/agents/pegasus-orchestrator.agent.md",
    target / ".github/instructions/pegasus-memory.instructions.md",
    target / ".github/instructions/pegasus-workflow.instructions.md",
    target / ".github/copilot-instructions.md",
)
supported = "`pending`, `in_progress`, `blocked`, `completed`"
for path in payload_guidance:
    text = path.read_text()
    assert supported in text, path
    assert "status `ready-for-review`" not in text, path
    assert "status `completed-as-draft`" not in text, path
PY
"$PYTHON_BIN" - "$target" <<'PY'
import sys
from pathlib import Path

target = Path(sys.argv[1])
guidance = (
    target / ".github/agents/pegasus-orchestrator.agent.md",
    target / ".github/agents/memory-maintainer.agent.md",
    target / ".github/instructions/pegasus-memory.instructions.md",
    target / ".github/instructions/pegasus-workflow.instructions.md",
    target / ".github/copilot-instructions.md",
)
legacy_alias_guidance = ("`kind`/`type`", "`kind` or `type`")
for path in guidance:
    text = path.read_text()
    assert "project_id" in text and "change_id" in text, path
    assert "kind" in text and "never send `type`" in text.lower(), path
    assert all(pattern not in text for pattern in legacy_alias_guidance), path
    assert "record_observation" in text and "record_artifact" in text, path
PY
for mcp_status in ensure_project ensure_change record_artifact record_observation record_task_progress record_handoff; do
  assert_file_contains "$target/.github/agents/sdd-spec.agent.md" "$mcp_status: <succeeded|not needed|failed: reason>"
done
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Decisions traceable to spec requirements or explicit technical evidence"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Do not implement code"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" 'current change'"'"'s `prd.md`, `proposal.md`, and `spec.md` exist and are approved in their files'
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Conversational approval never overrides"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Do not search, read, inspect, or reuse neighboring or unrelated change artifacts by default"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "existing system with implementation evidence"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Greenfield / no implementation evidence"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Greenfield / sin evidencia de implementación"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "both spaced and unspaced English variants"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "A blocking technical gap requires one concise question and a stop before writing or finalizing the design artifact"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "A non-blocking gap may remain stack-agnostic"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" 'In Greenfield context without concrete implementation stack, framework, or runtime evidence, `None` / `Ninguna` is invalid'
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "logical components, responsibilities, boundaries, interfaces, and control flow independently"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Never ask a required close-out question after completed-path persistence or finalization"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Trace decisions to a spec requirement or explicit evidence"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "<!-- pegasus-harness:start path=docs/pegasus/changes/<change-id>/design.md ownership=full-file -->"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Before completed-path Pegasus Memory artifact persistence, reread the artifact"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" 'reject untranslated structural vocabulary including `Inputs`, `Rationale`, `Tradeoffs`, `Unit`, and `Integration`'
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Pegasus Memory persistence summary:"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Artifact language: <selected language>"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Language gate: <passed|blocked: exact unresolved issues>"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Deferred technical choices: <structured summary of every choice and next gate|None / Ninguna>"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Explicit language override evidence: <exact user instruction/reference|None — English default enforced>"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Marker validation: <passed|blocked: exact marker issues>"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Traceability validation: <passed|blocked: exact per-entry traceability issues>"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Proposal risk coverage validation: <passed|blocked: exact missing risk/design/test coverage>"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Initial recovery result:"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Recovery/ensure transitions:"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Specialist agent: sdd-design"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Fresh-context delegation: confirmed by orchestrator invocation"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Artifact writer/validator/persistence owner: sdd-design"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Spanish chat, Spanish approved sources"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "every flow step, alternative, affected area, testing row, rollout/rollback row, and risk row"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Narrative prose does not satisfy the final-response contract"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" 'record_task_progress` for phase `design` before `record_handoff`'
assert_file_contains "$target/.github/agents/sdd-design.agent.md" 'Use `completed` only when the design is ready for review with no blocking gaps'
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Do not create tasks, work units, PR slices, implementation code"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "**Blocking path (approval/source or material technical blocker):** do not write/refine the design artifact"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "record_artifact: not needed — design artifact was not written because of blocking gap"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" 'status `blocked`, blockers/gaps, and next action `user answer`'
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "**Completed path:** only after marker, language, and gap validation"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "**Language-gate failure path:** the artifact may exist only as an unpersisted local draft"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "record_artifact: not needed — language validation failed before artifact persistence"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Never claim full durable success"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Treat completed-path closure as one atomic sequence"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" 'record_artifact` → `record_observation` → `record_task_progress` → `record_handoff`'
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "No artifact mutation is permitted after the first persistence operation begins"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "all earlier completion and persistence evidence is stale"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Final artifact revision:"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Persistence artifact revision:"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Post-persistence edits:"
for design_status in ensure_project ensure_change record_artifact record_observation record_task_progress record_handoff; do
  assert_file_contains "$target/.github/agents/sdd-design.agent.md" "$design_status: <succeeded|not needed|failed: reason>"
done
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "Decision needed before apply: Yes|No"
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "Chained PRs recommended: Yes|No"
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "400-line budget risk: Low|Medium|High"
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "Chain strategy: stacked-to-main|feature-branch-chain|size-exception|pending"
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "Estimated authored changed lines: <range>"
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "Estimated generated changed lines: <range|none>"
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "Tests included in estimate: Yes"
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "sole tasks artifact writer, validator, and persistence owner"
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" 'Construct the envelope `Artifact path` directly'
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" 'never copy, shorten, or derive it from a tool result'
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" 'exact equality between the constructed `Artifact path` and the supplied canonical output path'
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "fully reread the artifact"
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "exactly seven forecast lines and values"
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" 'persist `record_task_progress` for phase `tasks`, then `record_handoff`'
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "completion is blocked"
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" '"final_tasks_revision"'
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" '"persistence_tasks_revision"'
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" '"post_persistence_edits"'
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "Strategy decision evidence:"
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "Size-exception approval evidence:"
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "design recommendation, memory, cached preference, architecture, previous conversation/session, default, inference, or fabricated/generic text"
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "user selection alone is insufficient"
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "Calling or attempting \`record_task_progress\` or \`record_handoff\` before the SHA-256 revision is frozen is prohibited"
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "no artifact edits and no hash recomputation"
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" '"work_unit_count"'
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" '"assigned_scope"'
for work_unit_field in "Implementation scope:" "Test scope:" "Focused test command:" "Runtime validation:" "Rollback boundary:" "Estimated authored changed lines:"; do
  assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "$work_unit_field"
done
assert_file_contains "$target/.github/agents/sdd-tasks.agent.md" "Do not implement code"
assert_file_contains "$apply_reference" "approved next slice"
assert_file_contains "$apply_reference" "duplicate-check result"
assert_file_contains "$apply_reference" 'preliminary apply evidence does not replace verification'
assert_file_contains "$verify_reference" "Record a compliance matrix"
assert_file_contains "$verify_reference" "Do not make unrelated changes"
assert_file_contains "$verify_reference" "edit implementation unless the user separately authorizes a later remediation run"

orchestrator="$target/.github/agents/pegasus-orchestrator.agent.md"
assert_file_contains "$orchestrator" "thin coordinator, not a phase executor"
assert_file_contains "$orchestrator" "Every SDD phase MUST run through its matching specialized agent in a fresh context"
assert_file_contains "$orchestrator" "MUST NOT write phase artifacts, implement tasks, run phase tests/builds, or perform verification"
assert_file_contains "$orchestrator" "If required delegation is unavailable, blocked, or fails, stop and report"
assert_file_contains "$orchestrator" "validate only the returned specialist result envelope"
assert_file_contains "$orchestrator" "MUST NOT read or reread"
assert_file_contains "$orchestrator" "sole artifact writer, validator, and persistence owner"
assert_file_contains "$orchestrator" "A missing or partial envelope blocks success and phase advancement"
assert_file_contains "$orchestrator" "without claiming direct artifact validation"
assert_file_contains "$orchestrator" "explicitly ask the user to approve the design phase"
assert_file_contains "$orchestrator" "reproduce the COMPLETE specialist result envelope"
assert_file_contains "$orchestrator" "verbatim when possible, or field-for-field"
assert_file_contains "$orchestrator" "do not summarize success, request approval, or advance to tasks"
assert_file_contains "$orchestrator" 'checks only that `Proposal risk coverage validation` exists'
assert_file_contains "$orchestrator" 'Fail closed unless `Post-persistence edits: none` is exact'
assert_file_contains "$orchestrator" '¿Aprobás el diseño para avanzar a la fase de tareas?'
assert_file_contains "$target/.github/copilot-instructions.md" "MUST reproduce the complete canonical envelope verbatim or field-for-field"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" "MUST reproduce the complete canonical specialist envelope verbatim or field-for-field"
assert_file_contains "$target/.github/copilot-instructions.md" "Lossy narrative summarization MUST NOT substitute for complete envelope reproduction"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" "Lossy narrative summarization MUST NOT substitute for complete envelope reproduction"
assert_file_contains "$orchestrator" "understanding requires reading 4 or more files"
assert_file_contains "$orchestrator" "implementation touches 2 or more non-trivial files"
assert_file_contains "$orchestrator" "tests/builds/installs/external tooling must run"
assert_file_contains "$orchestrator" "stacked-to-main"
assert_file_contains "$orchestrator" "feature-branch-chain"
assert_file_contains "$orchestrator" 'maintainer-approved `size:exception`'
assert_file_contains "$orchestrator" "Copy the entire validated four-line v2 tasks block"
assert_file_contains "$orchestrator" "strategy narrative may state only the guard consequence derived from decoded values"
assert_file_contains "$orchestrator" 'La previsión requiere definir la estrategia antes de apply.'
assert_file_contains "$orchestrator" 'No se iniciará apply hasta que respondas.'
assert_file_contains "$orchestrator" "A request that asks only for tasks still requires this post-tasks review-guard question"
assert_file_contains "$orchestrator" 'Current change ID: <change-id>'
assert_file_contains "$orchestrator" 'Required canonical output path: docs/pegasus/changes/<change-id>/tasks.md'
assert_file_contains "$orchestrator" 'Backtick characters are not required in a flat export.'
assert_file_contains "$orchestrator" "Until that record exists, B2/apply is blocked"
assert_file_contains "$orchestrator" "change ID plus phase and, for apply, task-slice ID"
if grep -Eq '^  - (edit|execute)$' "$orchestrator"; then
  printf 'orchestrator must not expose phase execution tools\n' >&2
  exit 1
fi
for phase_agent in doc-designer sdd-proposal sdd-spec sdd-design sdd-tasks sdd-apply session-handoff; do
  assert_file_contains "$target/.github/agents/$phase_agent.agent.md" "Do not delegate or launch another agent for this phase."
done
assert_file_contains "$target/.github/agents/sdd-verify.agent.md" "Do not delegate, launch another agent, recursively invoke verify, or invoke apply."
assert_file_contains "$target/.github/agents/sdd-apply.agent.md" "return blocked before writing"
assert_file_contains "$target/.github/agents/sdd-apply.agent.md" 'distinct fresh-context `sdd-verify`'
assert_file_contains "$target/.github/agents/sdd-verify.agent.md" "directly in this fresh context"

assert_file_contains "$target/docs/pegasus/spec.md" "## Source Status"
assert_file_contains "$target/docs/pegasus/spec.md" "## Acceptance Edge Cases"
assert_file_contains "$target/docs/pegasus/spec.md" "## Non-Goals / Out of Scope"
assert_file_contains "$target/docs/pegasus/spec.md" "## Traceability"
assert_file_contains "$target/docs/pegasus/spec.md" "## Source Isolation"
assert_file_contains "$target/docs/pegasus/spec.md" "## Related Change Traceability"
assert_file_contains "$target/docs/pegasus/spec.md" "## Open Questions / Material Gaps"
assert_file_contains "$target/docs/pegasus/spec.md" "Every normative requirement MUST link"
assert_file_contains "$target/docs/pegasus/spec.md" "An ambiguous Pegasus Memory response never resolves a gap"
assert_file_contains "$target/docs/pegasus/spec.md" "Replace each placeholder with behavior explicitly supported"
assert_file_contains "$target/docs/pegasus/spec.md" "## Artifact Language"
assert_file_contains "$target/docs/pegasus/spec.md" "Use another artifact language only when the user explicitly names it"
assert_file_contains "$target/docs/pegasus/spec.md" "Do not mix English template headings with Spanish prose"
if grep -Fq "reject duplicate apply work" "$target/docs/pegasus/spec.md"; then
  printf 'spec template contains unrelated duplicate-apply behavior\n' >&2
  exit 1
fi
if grep -Fq "Duplicate apply slice is already complete" "$target/docs/pegasus/spec.md"; then
  printf 'spec template contains an unrelated duplicate-apply scenario\n' >&2
  exit 1
fi
assert_file_contains "$ROOT/templates/harness/docs/pegasus/spec.md" '<!-- pegasus-harness:start path=docs/pegasus/changes/<change-id>/spec.md ownership=full-file -->'
assert_file_contains "$ROOT/templates/harness/docs/pegasus/spec.md" '<!-- pegasus-harness:end path=docs/pegasus/changes/<change-id>/spec.md -->'
"$PYTHON_BIN" - "$ROOT/templates/harness/docs/pegasus/spec.md" <<'PY'
import sys
from pathlib import Path

lines = Path(sys.argv[1]).read_text().splitlines()
assert lines[0] == "<!-- pegasus-harness:start path=docs/pegasus/changes/<change-id>/spec.md ownership=full-file -->"
assert lines[-1] == "<!-- pegasus-harness:end path=docs/pegasus/changes/<change-id>/spec.md -->"
PY
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "For spec work, inspect the current change's PRD and proposal directly"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "Spec persistence: file-only"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "## Spec language quality gate"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "an explicit user artifact-language request wins"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "make no Pegasus Memory persistence call or success claim"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "require \`Creado:\` and \`Destino:\`; reject \`Created:\`, \`Target:\`"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "This scan is structural only and MUST allow standardized \`GIVEN\` / \`WHEN\` / \`THEN\`"
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" "For spec work, select one artifact language before writing"
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" "Repair only affected language blocks, reread the entire artifact, revalidate markers, and rerun the gate"
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" "Spec persistence: file-only — language validation failed: <exact issues>"
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" "require \`Creado:\` and \`Destino:\`; reject \`Created:\`, \`Target:\`"
assert_file_contains "$target/.github/copilot-instructions.md" "For spec work, select one artifact language before writing"
assert_file_contains "$target/.github/copilot-instructions.md" 'State `Artifact language: <selected language>` and `Language gate: <passed|blocked: exact unresolved issues>`'
assert_file_contains "$target/.github/copilot-instructions.md" "Language gate: passed\` is forbidden while any prohibited English structural label remains"
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" "Before spec drafting, inspect the current change PRD and proposal artifacts"
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" "Spec stays acceptance-only"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "For spec closure"
assert_file_contains "$target/.github/copilot-instructions.md" "Before spec, inspect the current change's PRD and proposal"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" 'scenarios in `docs/pegasus/changes/<change-id>/spec.md`'
if grep -Fq 'scenarios in `docs/pegasus/spec.md`' "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md"; then
  printf 'stable spec contains contradictory root spec path for change-scoped flow\n' >&2
  exit 1
fi
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" "if repair and reread still fail validation, it MUST block Pegasus Memory persistence and success"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" "Pegasus Memory persistence summary:"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" 'record_task_progress` before `record_handoff`'
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" 'MUST NOT claim `succeeded` for a call that was omitted'
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" "other MCP servers may also be connected"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" "Spec persistence: file-only — <reason>"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" "Pegasus Memory persistence incomplete/partial — <failed operation>: <reason>"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" "prevent a full durable-completion or Pegasus Memory-success claim"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" "explicit user instruction naming the spec language takes precedence, otherwise it MUST use English"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" "chat language, persona language, dominant approved-source language, and prior artifact language MUST NOT override"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" "untranslated canonical headings/labels"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" "malformed or near-match terms"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" "repair only affected language blocks, reread the complete artifact, revalidate markers, and rerun"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" "MUST NOT persist or claim success"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" "Language gate: <passed|blocked: exact unresolved issues>"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" "require \`Creado:\` and \`Destino:\` and reject \`Created:\`, \`Target:\`"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" "structural-label scan MUST allow standardized \`GIVEN\` / \`WHEN\` / \`THEN\`"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" "MUST NOT report \`Language gate: passed\` while any prohibited English structural label remains"
assert_file_contains "$target/docs/pegasus/design.md" "## Inputs"
assert_file_contains "$target/docs/pegasus/design.md" "## Design Goals / Non-Goals"
assert_file_contains "$target/docs/pegasus/design.md" "## Alternatives Considered"
assert_file_contains "$target/docs/pegasus/design.md" "## Data / Control Flow"
assert_file_contains "$target/docs/pegasus/design.md" "## Rollout / Rollback"
assert_file_contains "$target/docs/pegasus/design.md" "Alternative | Why not chosen | Requirement / evidence traceability | Tradeoff | When to revisit"
assert_file_contains "$target/docs/pegasus/design.md" "Topic | Plan | Requirement / evidence traceability | Trigger"
assert_file_contains "$target/docs/pegasus/design.md" "## Technical Context Classification"
assert_file_contains "$target/docs/pegasus/design.md" "## Material Technical Decisions and Gaps"
assert_file_contains "$target/docs/pegasus/design.md" "Validation mapping for an explicit Spanish override only"
assert_file_contains "$target/docs/pegasus/design.md" "Pegasus Memory context"
assert_file_contains "$target/docs/pegasus/design.md" "Invariant architecture"
assert_file_contains "$target/docs/pegasus/design.md" "Deferred choice"
assert_file_contains "$target/docs/pegasus/design.md" "Why non-blocking"
assert_file_contains "$target/docs/pegasus/design.md" "Evidence / traceability"
assert_file_contains "$target/docs/pegasus/design.md" "canonical template only"
assert_file_contains "$target/docs/pegasus/design.md" "## Deferred Technical Choices"
assert_file_contains "$target/docs/pegasus/design.md" "## Proposal Risk Coverage"
assert_file_contains "$target/docs/pegasus/design.md" "Mobile rendering performance"
assert_file_contains "$target/docs/pegasus/design.md" "Proposal risk reference | Design risk entry | Mitigation | Test / measurement entry or N/A rationale | Owner | Trigger"
assert_file_contains "$target/docs/pegasus/design.md" "Choice / topic | Status | Owner | Impact | Next step | Needed-by gate | Invariant architecture | Why non-blocking | Evidence / source"
assert_file_contains "$target/docs/pegasus/design.md" "| None | N/A |"
assert_file_contains "$target/docs/pegasus/design.md" 'in Greenfield context without concrete implementation stack, framework, or runtime evidence, `None` (or its selected-language translation) is invalid'
assert_file_contains "$target/docs/pegasus/design.md" "Decisiones y compensaciones"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "canonical status \`deferred-non-blocking\`"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "A missing deferred field is blocking"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" 'The final response uses the exact `Deferred technical choices:` label'
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "every deferred choice (or \`None\` / \`Ninguna\`), its needed-by gate"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "dedicated \`Deferred Technical Choices\` table"
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" "Reconcile deferred technical choices before marker, language, and persistence gates"
assert_file_contains "$target/docs/pegasus/design.md" "Pegasus Memory product naming"
assert_file_contains "$target/docs/pegasus/design.md" "Validate every \`MCP\` occurrence independently"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "Allow \`MCP\` only in an explicit protocol discussion"
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "standalone/generic \`MCP\`"
assert_file_contains "$target/.github/agents/sdd-design.agent.md" "does not permit a separate standalone \`MCP\` occurrence"
assert_file_contains "$ROOT/templates/harness/docs/pegasus/design.md" '<!-- pegasus-harness:start path=docs/pegasus/changes/<change-id>/design.md ownership=full-file -->'
assert_file_contains "$ROOT/templates/harness/docs/pegasus/design.md" '<!-- pegasus-harness:end path=docs/pegasus/changes/<change-id>/design.md -->'
"$PYTHON_BIN" - "$target/.github/agents/sdd-design.agent.md" "$target/docs/pegasus/design.md" <<'PY'
import sys
from pathlib import Path

guidance = Path(sys.argv[1]).read_text()
template = Path(sys.argv[2]).read_text()
assert guidance.index("A blocking technical gap") < guidance.index("## Managed artifact")
assert guidance.index("Before completed-path Pegasus Memory artifact persistence, reread") < guidance.index("## Pegasus Memory closure contract")
assert guidance.index("record_task_progress` for phase `design` occurs before `record_handoff`") < guidance.index("Do not return until all six operations")
assert guidance.index("**Blocking path (approval/source or material technical blocker):**") < guidance.index("**Completed path:**")
assert guidance.index("record_observation") < guidance.index("record_task_progress") < guidance.index("record_handoff")
assert guidance.index("Repair affected blocks, reread the whole artifact, revalidate markers, and rerun the gate") < guidance.index("An unresolved language gate failure blocks artifact persistence and success")
assert "Use generic MCP terminology" not in guidance
for field in (
    "Status:", "Specialist agent:", "Fresh-context delegation:", "Artifact path:",
    "Artifact writer/validator/persistence owner:", "Artifact language:", "Explicit language override evidence:",
    "Language gate:", "Marker validation:", "Traceability validation:",
    "Proposal risk coverage validation:", "Deferred technical choices:",
    "Initial recovery result:", "Recovery/ensure transitions:", "Pegasus Memory persistence summary:",
    "Final artifact revision:", "Persistence artifact revision:", "Post-persistence edits:",
    "Risks/blockers:", "Next action:",
):
    assert field in guidance
for section in ("flow step", "alternative", "affected area", "testing row", "rollout/rollback row", "risk row"):
    assert section in guidance.lower()
assert "<!-- pegasus-harness:start path=docs/pegasus/changes/<change-id>/design.md ownership=full-file -->" in template
assert "<!-- pegasus-harness:end path=docs/pegasus/changes/<change-id>/design.md -->" in template
for text in ("Technical Context Classification", "Material Technical Decisions and Gaps", "Validation mapping for an explicit Spanish override only"):
    assert text in template

required_persistence = ["record_artifact", "record_observation", "record_task_progress", "record_handoff"]

def valid_atomic_trace(events: list[str]) -> bool:
    first_write = next((index for index, event in enumerate(events) if event in required_persistence), len(events))
    if any(event == "edit_artifact" for event in events[first_write + 1:]):
        return False
    writes = [event for event in events if event in required_persistence]
    return writes == required_persistence

assert valid_atomic_trace([
    "edit_artifact", "full_reread", "validate_all", "freeze_revision",
    "ensure_project", "ensure_change", *required_persistence, "return_envelope",
])
for operation in required_persistence:
    trace = ["edit_artifact", "full_reread", "validate_all", "freeze_revision"]
    for current in required_persistence:
        trace.append(current)
        if current == operation:
            trace.append("edit_artifact")
    assert not valid_atomic_trace(trace), operation
assert not valid_atomic_trace(["edit_artifact", "full_reread", "validate_all", "freeze_revision", "record_observation", "record_artifact", "record_task_progress", "record_handoff"])
PY
"$PYTHON_BIN" - "$target/.github/agents/pegasus-orchestrator.agent.md" <<'PY'
import sys
from pathlib import Path

guidance = Path(sys.argv[1]).read_text()
fields = (
    "Status", "Specialist agent", "Fresh-context delegation", "Artifact path",
    "Artifact writer/validator/persistence owner", "Artifact language",
    "Explicit language override evidence", "Language gate", "Marker validation",
    "Traceability validation", "Proposal risk coverage validation",
    "Deferred technical choices", "Initial recovery result", "Recovery/ensure transitions",
    "Final artifact revision", "Persistence artifact revision", "Post-persistence edits",
    "Risks/blockers", "Next action",
)
operations = (
    "ensure_project", "ensure_change", "record_artifact", "record_observation",
    "record_task_progress", "record_handoff",
)

def validate_envelope(text: str) -> bool:
    lines = text.splitlines()
    labels = {line.split(":", 1)[0] for line in lines if ":" in line}
    if not all(field in labels for field in fields):
        return False
    if "Pegasus Memory persistence summary:" not in lines:
        return False
    values = dict(line.split(": ", 1) for line in lines if ": " in line)
    if values.get("Post-persistence edits") != "none":
        return False
    if values.get("Final artifact revision") != values.get("Persistence artifact revision"):
        return False
    return all(any(line.startswith(f"{operation}: ") for line in lines) for operation in operations)

complete = "\n".join([
    "Status: completed",
    "Specialist agent: sdd-design",
    "Fresh-context delegation: confirmed by orchestrator invocation",
    "Artifact path: docs/pegasus/changes/mobile/design.md",
    "Artifact writer/validator/persistence owner: sdd-design",
    "Artifact language: English",
    "Explicit language override evidence: None — English default enforced",
    "Language gate: passed",
    "Marker validation: passed",
    "Traceability validation: passed",
    "Proposal risk coverage validation: passed",
    "Deferred technical choices: None",
    "Initial recovery result: not_found",
    "Recovery/ensure transitions: ensure_project succeeded -> ensure_change succeeded",
    "Final artifact revision: sha256:abc123",
    "Persistence artifact revision: sha256:abc123",
    "Post-persistence edits: none",
    "Risks/blockers: None",
    "Next action: review/approval",
    "Pegasus Memory persistence summary:",
    *[f"{operation}: succeeded" for operation in operations],
])

def orchestrator_final(specialist_result: str) -> str:
    if not validate_envelope(specialist_result):
        return "Status: blocked\nRisks/blockers: incomplete specialist result envelope"
    return specialist_result + "\n¿Aprobás el diseño para avanzar a la fase de tareas?"

assert orchestrator_final(complete) == complete + "\n¿Aprobás el diseño para avanzar a la fase de tareas?"
partial = complete.replace("Proposal risk coverage validation: passed\n", "")
assert not validate_envelope(partial)
assert orchestrator_final(partial) != partial
assert "blocked" in orchestrator_final(partial)
mismatch = complete.replace("Persistence artifact revision: sha256:abc123", "Persistence artifact revision: sha256:def456")
assert not validate_envelope(mismatch)
edited = complete.replace("Post-persistence edits: none", "Post-persistence edits: detected: formatting rewrite")
assert not validate_envelope(edited)
rephrased = complete.replace("Post-persistence edits: none", "No edits after persistence: true")
assert not validate_envelope(rephrased)
assert "¿Aprobás el diseño para avanzar a la fase de tareas?" in orchestrator_final(complete)
assert "Next action: review/approval" in complete
assert "reproduce the COMPLETE specialist result envelope" in guidance
assert "do not summarize success, request approval, or advance to tasks" in guidance
PY
"$PYTHON_BIN" - "$target/.github/agents/sdd-tasks.agent.md" "$target/.github/agents/pegasus-orchestrator.agent.md" "$ROOT/templates/harness/docs/pegasus/tasks.md" <<'PY'
import re
import sys
from pathlib import Path

specialist_guidance, orchestrator_guidance, template = (Path(path).read_text() for path in sys.argv[1:])
forecast_fields = (
    "Decision needed before apply", "Chained PRs recommended", "Chain strategy",
    "400-line budget risk", "Estimated authored changed lines",
    "Estimated generated changed lines", "Tests included in estimate",
)
strategy_evidence_field = "Strategy decision evidence"
approval_evidence_field = "Size-exception approval evidence"
envelope_fields = (
    "Status", "Specialist agent", "Fresh-context delegation", "Artifact path",
    "Artifact writer/validator/persistence owner", "Artifact language",
    "Explicit language override evidence", "Language gate", "Marker validation",
    "Source identity validation", "Work-unit validation", "Forecast validation",
    *forecast_fields, strategy_evidence_field, approval_evidence_field,
    "Work-unit count", "Assigned scope", "Final tasks revision",
    "Persistence tasks revision", "Post-persistence edits", "Initial recovery result",
    "Recovery/ensure transitions", "Risks/blockers", "Decision required", "Next action",
)
operations = ("ensure_project", "ensure_change", "record_task_progress", "record_handoff")
canonical_artifact_path = "docs/pegasus/changes/mobile/tasks.md"

handoff_match = re.search(r'(?m)^  - label: Plan tasks\n    agent: sdd-tasks\n    prompt: "([^"]+)"$', orchestrator_guidance)
assert handoff_match
delegated_prompt = handoff_match.group(1).replace(r"\n", "\n")
required_prompt_data = (
    "Current change ID: <change-id>",
    "Required canonical output path: docs/pegasus/changes/<change-id>/tasks.md",
    "Approved artifact references:",
    "docs/pegasus/changes/<change-id>/prd.md",
    "docs/pegasus/changes/<change-id>/proposal.md",
    "docs/pegasus/changes/<change-id>/spec.md",
    "docs/pegasus/changes/<change-id>/design.md",
    "Scope: tasks only.",
    "Boundary: Do not implement or launch apply.",
)
for required in required_prompt_data:
    assert required in delegated_prompt

forbidden_prompt_hints = (
    r"forecast", r"chain strategy", r"stacked-to-main", r"feature-branch-chain", r"size:exception",
    r"budget risk", r"\b(?:low|medium|high) risk\b", r"estimated .*changed lines", r"\b[0-9,]+-[0-9,]+\b",
    r"tests included", r"work-unit count", r"strategy decision evidence", r"size-exception approval evidence",
    r"decision evidence none", r"strategy pending",
)
def valid_tasks_delegation_prompt(prompt: str) -> bool:
    return all(required in prompt for required in required_prompt_data) and not any(
        re.search(pattern, prompt, re.IGNORECASE) for pattern in forbidden_prompt_hints
    )

assert valid_tasks_delegation_prompt(delegated_prompt)
for forbidden_fixture in (
    "Forecast validation: passed", "Chain strategy: pending", "400-line budget risk: High",
    "Estimated authored changed lines: 590-720", "Tests included in estimate: Yes",
    "Work-unit count: 3", "Strategy decision evidence: none", "Size-exception approval evidence: none",
):
    assert not valid_tasks_delegation_prompt(f"{delegated_prompt}\n{forbidden_fixture}"), forbidden_fixture

def valid_current_strategy_evidence(strategy: str, evidence_id: str, evidence_events: dict[str, dict[str, object]]) -> bool:
    event = evidence_events.get(evidence_id, {})
    return all((
        event.get("source") == "current_user",
        event.get("session") == "current",
        event.get("kind") == "strategy_selection",
        event.get("strategy") == strategy,
        event.get("explicit") is True,
    ))

def valid_size_approval(evidence_id: str, selection_id: str, evidence_events: dict[str, dict[str, object]]) -> bool:
    event = evidence_events.get(evidence_id, {})
    return evidence_id != selection_id and all((
        event.get("source") == "maintainer",
        event.get("session") == "current",
        event.get("kind") == "size_exception_approval",
        event.get("strategy") == "size:exception",
        event.get("explicit") is True,
    ))

def validate_envelope(text: str, evidence_events: dict[str, dict[str, object]] | None = None) -> bool:
    evidence_events = evidence_events or {}
    lines = text.splitlines()
    labels = {line.split(":", 1)[0] for line in lines if ":" in line}
    values = dict(line.split(": ", 1) for line in lines if ": " in line)
    if not all(field in labels for field in envelope_fields):
        return False
    if "Pegasus Memory persistence summary:" not in lines:
        return False
    if values.get("Artifact path") != canonical_artifact_path:
        return False
    if values.get("Post-persistence edits") != "none":
        return False
    if values.get("Final tasks revision") != values.get("Persistence tasks revision"):
        return False
    strategy = values.get("Chain strategy")
    selection_id = values.get(strategy_evidence_field)
    approval_id = values.get(approval_evidence_field)
    if strategy == "pending":
        if selection_id != "none" or approval_id != "none":
            return False
    elif strategy not in {"stacked-to-main", "feature-branch-chain", "size:exception"}:
        return False
    elif not valid_current_strategy_evidence(strategy, selection_id or "", evidence_events):
        return False
    elif strategy == "size:exception":
        if not valid_size_approval(approval_id or "", selection_id or "", evidence_events):
            return False
    elif approval_id != "none":
        return False
    if values.get("record_handoff invocation") not in {"call-final-abc123", "not observable"}:
        return False
    return all(values.get(operation) in {"succeeded", "not needed"} for operation in operations)

def valid_estimate_breakdown(unit: dict[str, tuple[int, int] | None]) -> bool:
    components = [unit.get(name) for name in ("code", "tests", "docs", "config")]
    total = unit.get("total")
    if any(value is None for value in components) or total is None or "generated" not in unit:
        return False
    if any(value[0] < 0 or value[0] > value[1] for value in (*components, total)):
        return False
    minimum = sum(value[0] for value in components if value is not None)
    maximum = sum(value[1] for value in components if value is not None)
    return total == (minimum, maximum)

def valid_global_estimate(units: list[dict[str, tuple[int, int] | None]], forecast: tuple[int, int]) -> bool:
    if not all(valid_estimate_breakdown(unit) for unit in units):
        return False
    totals = [unit["total"] for unit in units]
    return forecast == (sum(total[0] for total in totals), sum(total[1] for total in totals))

valid_units = [
    {"code": (100, 120), "tests": (40, 50), "docs": (10, 15), "config": (0, 0), "total": (150, 185), "generated": None},
    {"code": (120, 140), "tests": (50, 60), "docs": (5, 10), "config": (5, 5), "total": (180, 215), "generated": None},
    {"code": (90, 110), "tests": (50, 60), "docs": (100, 130), "config": (20, 20), "total": (260, 320), "generated": None},
]
assert valid_global_estimate(valid_units, (590, 720))
assert not valid_estimate_breakdown({**valid_units[0], "config": (5, 4)})
b1_068_wu3 = {"code": (90, 110), "tests": (50, 60), "docs": (55, 55), "config": (0, 0), "total": (195, 210), "generated": None}
assert sum(b1_068_wu3[name][1] for name in ("code", "tests", "docs", "config")) == 225
assert not valid_estimate_breakdown(b1_068_wu3)
assert not valid_global_estimate([*valid_units[:2], b1_068_wu3], (525, 610))

def valid_dependency_graph(units: dict[str, dict[str, set[str]]]) -> bool:
    names = set(units)
    for name, links in units.items():
        if name in links["depends"] or not links["depends"] <= names or not links["required_by"] <= names:
            return False
        if any(name not in units[dependency]["required_by"] for dependency in links["depends"]):
            return False
        if any(name not in units[dependent]["depends"] for dependent in links["required_by"]):
            return False
    visiting, visited = set(), set()
    def visit(name: str) -> bool:
        if name in visiting:
            return False
        if name in visited:
            return True
        visiting.add(name)
        if not all(visit(dependency) for dependency in units[name]["depends"]):
            return False
        visiting.remove(name)
        visited.add(name)
        return True
    return all(visit(name) for name in names)

def exactly_one_handoff(events: list[tuple[str, str]]) -> bool:
    invocations = {identity for kind, identity in events if kind == "invocation"}
    successful = {identity for kind, identity in events if kind == "result:succeeded"}
    return len(invocations) == 1 and invocations == successful

def parse_tool_events(raw: str) -> list[tuple[str, str | None]]:
    parsed = []
    for line in raw.splitlines():
        event, separator, revision = line.partition(" revision=")
        parsed.append((event, revision if separator else None))
    return parsed

def valid_atomic_trace(raw: str, frozen_revision: str) -> bool:
    events = parse_tool_events(raw)
    names = [event for event, _ in events]
    validation = names.index("validate_all") if "validate_all" in names else len(names)
    freeze = names.index("freeze_sha256") if "freeze_sha256" in names else -1
    persistence_indexes = [names.index(op) for op in operations[2:] if op in names]
    first_persist = min(persistence_indexes, default=-1)
    if not (validation < freeze < first_persist):
        return False
    if names[first_persist:first_persist + 2] != list(operations[2:]):
        return False
    if any(event in {"edit_artifact", "freeze_sha256"} for event in names[freeze + 1:]):
        return False
    revisions = [revision for event, revision in events if event in operations[2:]]
    return revisions == [frozen_revision, frozen_revision]

complete = "\n".join([
    "Status: completed", "Specialist agent: sdd-tasks",
    "Fresh-context delegation: confirmed by orchestrator invocation",
    "Artifact path: docs/pegasus/changes/mobile/tasks.md",
    "Artifact writer/validator/persistence owner: sdd-tasks", "Artifact language: English",
    "Explicit language override evidence: None — English default enforced", "Language gate: passed",
    "Marker validation: passed", "Source identity validation: passed", "Work-unit validation: passed",
    "Forecast validation: passed", "Decision needed before apply: Yes",
    "Chained PRs recommended: Yes", "Chain strategy: pending", "Strategy decision evidence: none",
    "Size-exception approval evidence: none",
    "400-line budget risk: High", "Estimated authored changed lines: 590-720", "Estimated generated changed lines: 40-60",
    "Tests included in estimate: Yes", "Work-unit count: 3",
    "Assigned scope: WU1 behavior+tests; WU2 integration+tests; WU3 docs+smoke",
    "Final tasks revision: sha256:abc123", "Persistence tasks revision: sha256:abc123",
    "Post-persistence edits: none", "Initial recovery result: found",
    "Recovery/ensure transitions: found -> ensure_project not needed -> ensure_change not needed",
    "Pegasus Memory persistence summary:", "ensure_project: not needed", "ensure_change: not needed",
    "record_task_progress: succeeded", "record_handoff: succeeded", "record_handoff invocation: call-final-abc123",
    "Risks/blockers: High review load",
    "Decision required: Yes", "Next action: user strategy decision",
])
assert validate_envelope(complete)
v2_keys = (
    "status", "specialist_agent", "fresh_context_delegation", "artifact_path", "artifact_owner",
    "artifact_language", "language_override_evidence", "language_gate", "marker_validation",
    "source_identity_validation", "work_unit_validation", "forecast_validation",
    "decision_needed_before_apply", "chained_prs_recommended", "chain_strategy",
    "strategy_decision_evidence", "size_exception_approval_evidence", "budget_risk_400_line",
    "estimated_authored_changed_lines", "estimated_generated_changed_lines", "tests_included_in_estimate",
    "work_unit_count", "assigned_scope", "final_tasks_revision", "persistence_tasks_revision",
    "post_persistence_edits", "initial_recovery_result", "recovery_ensure_transitions",
    *operations, "record_handoff_invocation", "risks_blockers", "decision_required", "next_action",
)
for field in v2_keys:
    assert f'"{field}"' in specialist_guidance, field
assert all(field in orchestrator_guidance for field in forecast_fields)
valid_events = "\n".join((
    "edit_artifact", "full_reread", "validate_all", "freeze_sha256",
    "ensure_project", "ensure_change", "record_task_progress revision=sha256:abc123",
    "record_handoff revision=sha256:abc123", "return_envelope",
))
assert valid_atomic_trace(valid_events, "sha256:abc123")
assert not valid_atomic_trace("\n".join(("edit_artifact", "full_reread", "record_task_progress revision=sha256:abc123", "validate_all", "freeze_sha256", "record_handoff revision=sha256:abc123")), "sha256:abc123")
assert not valid_atomic_trace("\n".join(("edit_artifact", "full_reread", "validate_all", "record_task_progress revision=sha256:abc123", "freeze_sha256", "record_handoff revision=sha256:abc123")), "sha256:abc123")
assert not valid_atomic_trace("\n".join(("edit_artifact", "full_reread", "validate_all", "freeze_sha256", "record_task_progress revision=sha256:abc123", "edit_artifact", "record_handoff revision=sha256:abc123")), "sha256:abc123")
assert not valid_atomic_trace("\n".join(("edit_artifact", "full_reread", "validate_all", "freeze_sha256", "record_task_progress revision=sha256:abc123", "freeze_sha256", "record_handoff revision=sha256:def456")), "sha256:abc123")
assert not validate_envelope(complete.replace("Forecast validation: passed\n", ""))
assert not validate_envelope(complete.replace("Persistence tasks revision: sha256:abc123", "Persistence tasks revision: sha256:def456"))
assert not validate_envelope(complete.replace("Post-persistence edits: none", "Post-persistence edits: detected: rewrite"))
assert not validate_envelope(complete.replace("Chain strategy: pending", "Chain strategy: feature-branch-chain"))
assert not validate_envelope(complete.replace(canonical_artifact_path, "tasks.md"))
assert not validate_envelope(complete.replace(canonical_artifact_path, "docs/tasks.md"))
assert not validate_envelope(complete.replace(canonical_artifact_path, "/workspace/docs/pegasus/changes/mobile/tasks.md"))
assert not validate_envelope(complete.replace(canonical_artifact_path, "docs/pegasus/changes/other-change/tasks.md"))
assert not validate_envelope(complete.replace("Strategy decision evidence: none\n", ""))
assert not validate_envelope(complete.replace("Size-exception approval evidence: none\n", ""))

valid_breakdown = {"code": (120, 140), "tests": (50, 60), "docs": (0, 0), "config": (10, 15), "total": (180, 215), "generated": None}
assert valid_estimate_breakdown(valid_breakdown)
assert not valid_estimate_breakdown({key: value for key, value in valid_breakdown.items() if key != "docs"})
assert not valid_estimate_breakdown({**valid_breakdown, "total": (100, 120)})
valid_dependencies = {
    "WU1": {"depends": set(), "required_by": {"WU2"}},
    "WU2": {"depends": {"WU1"}, "required_by": {"WU3"}},
    "WU3": {"depends": {"WU2"}, "required_by": set()},
}
assert valid_dependency_graph(valid_dependencies)
contradiction = {name: {key: set(value) for key, value in links.items()} for name, links in valid_dependencies.items()}
contradiction["WU1"]["required_by"] = set()
assert not valid_dependency_graph(contradiction)
cycle = {name: {key: set(value) for key, value in links.items()} for name, links in valid_dependencies.items()}
cycle["WU1"]["depends"] = {"WU3"}
cycle["WU3"]["required_by"] = {"WU1"}
assert not valid_dependency_graph(cycle)
assert exactly_one_handoff([("invocation", "call-final"), ("result:succeeded", "call-final")])
assert not exactly_one_handoff([("invocation", "call-1"), ("result:succeeded", "call-1"), ("invocation", "call-2"), ("result:succeeded", "call-2")])

evidence_events = {
    "current-stacked": {"source": "current_user", "session": "current", "kind": "strategy_selection", "strategy": "stacked-to-main", "explicit": True},
    "current-feature": {"source": "current_user", "session": "current", "kind": "strategy_selection", "strategy": "feature-branch-chain", "explicit": True},
    "current-size": {"source": "current_user", "session": "current", "kind": "strategy_selection", "strategy": "size:exception", "explicit": True},
    "current-size-approval": {"source": "maintainer", "session": "current", "kind": "size_exception_approval", "strategy": "size:exception", "explicit": True},
    "design-recommendation": {"source": "design", "session": "current", "kind": "strategy_selection", "strategy": "feature-branch-chain", "explicit": True},
    "memory-preference": {"source": "memory", "session": "current", "kind": "strategy_selection", "strategy": "stacked-to-main", "explicit": True},
    "cached-preference": {"source": "cached_preference", "session": "current", "kind": "strategy_selection", "strategy": "stacked-to-main", "explicit": True},
    "architecture-recommendation": {"source": "architecture", "session": "current", "kind": "strategy_selection", "strategy": "feature-branch-chain", "explicit": True},
    "previous-conversation": {"source": "current_user", "session": "previous", "kind": "strategy_selection", "strategy": "stacked-to-main", "explicit": True},
    "default-choice": {"source": "default", "session": "current", "kind": "strategy_selection", "strategy": "stacked-to-main", "explicit": True},
    "inferred-choice": {"source": "inference", "session": "current", "kind": "strategy_selection", "strategy": "feature-branch-chain", "explicit": True},
    "fabricated-generic": {"source": "generated_text", "session": "current", "kind": "strategy_selection", "strategy": "stacked-to-main", "explicit": True},
}

def resolved_envelope(strategy: str, selection_id: str, approval_id: str = "none") -> str:
    return complete.replace("Chain strategy: pending", f"Chain strategy: {strategy}").replace(
        "Strategy decision evidence: none", f"Strategy decision evidence: {selection_id}"
    ).replace("Size-exception approval evidence: none", f"Size-exception approval evidence: {approval_id}")

stacked = resolved_envelope("stacked-to-main", "current-stacked")
feature = resolved_envelope("feature-branch-chain", "current-feature")
size_approved = resolved_envelope("size:exception", "current-size", "current-size-approval")
size_unapproved = resolved_envelope("size:exception", "current-size")
assert validate_envelope(stacked, evidence_events)
assert validate_envelope(feature, evidence_events)
assert validate_envelope(size_approved, evidence_events)
assert not validate_envelope(size_unapproved, evidence_events)
for invalid_id in (
    "design-recommendation", "memory-preference", "cached-preference", "architecture-recommendation",
    "previous-conversation", "default-choice", "inferred-choice", "fabricated-generic",
):
    assert not validate_envelope(resolved_envelope("stacked-to-main", invalid_id), evidence_events), invalid_id

strategy_question = "La previsión requiere definir la estrategia antes de apply. ¿Elegís `stacked-to-main`, `feature-branch-chain` o una excepción `size:exception` aprobada por el maintainer? No se iniciará apply hasta que respondas."
plain_strategy_question = strategy_question.replace("`", "")
def valid_exported_strategy_question(question: str) -> bool:
    return question.replace("`", "") == plain_strategy_question

assert valid_exported_strategy_question(strategy_question)
assert valid_exported_strategy_question(plain_strategy_question)
assert not valid_exported_strategy_question(plain_strategy_question.replace("feature-branch-chain", "feature-chain"))
assert not valid_exported_strategy_question(plain_strategy_question.replace("stacked-to-main, feature-branch-chain", "feature-branch-chain, stacked-to-main"))
assert not valid_exported_strategy_question(plain_strategy_question.replace("Elegís", "Preferís"))
assert not valid_exported_strategy_question(plain_strategy_question.replace(" No se iniciará apply hasta que respondas.", ""))
def may_launch_apply(envelope: str, evidence_events: dict[str, dict[str, object]]) -> bool:
    values = dict(line.split(": ", 1) for line in envelope.splitlines() if ": " in line)
    gated = values.get("Decision needed before apply") == "Yes" or values.get("Chained PRs recommended") == "Yes" or values.get("400-line budget risk") == "High"
    return validate_envelope(envelope, evidence_events) and (not gated or values.get("Chain strategy") != "pending")
assert not may_launch_apply(complete, evidence_events)
assert may_launch_apply(stacked, evidence_events)
assert may_launch_apply(feature, evidence_events)
assert may_launch_apply(size_approved, evidence_events)
assert not may_launch_apply(size_unapproved, evidence_events)
assert not may_launch_apply(resolved_envelope("feature-branch-chain", "design-recommendation"), evidence_events)
assert all(option in strategy_question for option in ("stacked-to-main", "feature-branch-chain", "size:exception"))
generic_pause = "La previsión requiere una decisión. ¿Cómo seguimos?"
assert not all(option in generic_pause for option in ("stacked-to-main", "feature-branch-chain", "size:exception"))
assert "No se iniciará apply hasta que respondas." in strategy_question
paraphrased_question = strategy_question.replace("Elegís", "Preferís")
assert paraphrased_question != strategy_question
assert orchestrator_guidance.replace("\\`", "`").count(strategy_question) == 1

def orchestrator_flat_output(envelope: str) -> str:
    if not validate_envelope(envelope):
        return "Status: blocked\nRisks/blockers: invalid tasks envelope"
    return envelope

flat_output = orchestrator_flat_output(complete)
for label in (*envelope_fields, *operations):
    assert f"{label}:" in flat_output
for exact_line in (
    "Estimated authored changed lines: 590-720", "Estimated generated changed lines: 40-60",
    "400-line budget risk: High", "Tests included in estimate: Yes", "Work-unit count: 3",
):
    assert exact_line in flat_output
partial_output = complete.replace("Estimated generated changed lines: 40-60\n", "")
assert orchestrator_flat_output(partial_output).startswith("Status: blocked")
generic_output = "Forecast is High and around six hundred authored lines with tests across three units."
assert orchestrator_flat_output(generic_output).startswith("Status: blocked")
lines = template.splitlines()
assert lines[0] == "<!-- pegasus-harness:start path=docs/pegasus/changes/<change-id>/tasks.md ownership=full-file -->"
assert lines[-1] == "<!-- pegasus-harness:end path=docs/pegasus/changes/<change-id>/tasks.md -->"
for exact_pending_line in ("Strategy decision evidence: <exact current-session user quote/message reference|none>", "Size-exception approval evidence: <distinct current maintainer approval quote/message reference|none>"):
    assert exact_pending_line in template
PY
"$PYTHON_BIN" - "$target/.github/agents/sdd-tasks.agent.md" "$target/.github/agents/pegasus-orchestrator.agent.md" <<'PY'
import hashlib
import json
import sys
from pathlib import Path

specialist, orchestrator = (Path(path).read_text() for path in sys.argv[1:])
begin = "=== PEGASUS SPECIALIST RESULT BEGIN v2 ==="
end = "=== PEGASUS SPECIALIST RESULT END v2 ==="
legacy_begin = "=== PEGASUS SPECIALIST RESULT BEGIN v1 ==="
legacy_end = "=== PEGASUS SPECIALIST RESULT END v1 ==="
keys = [
    "schema", "status", "specialist_agent", "fresh_context_delegation", "artifact_path",
    "artifact_owner", "artifact_language", "language_override_evidence", "language_gate",
    "marker_validation", "source_identity_validation", "work_unit_validation", "forecast_validation",
    "decision_needed_before_apply", "chained_prs_recommended", "chain_strategy",
    "strategy_decision_evidence", "size_exception_approval_evidence", "budget_risk_400_line",
    "estimated_authored_changed_lines", "estimated_generated_changed_lines",
    "tests_included_in_estimate", "work_unit_count", "assigned_scope", "final_tasks_revision",
    "persistence_tasks_revision", "post_persistence_edits", "initial_recovery_result",
    "recovery_ensure_transitions", "ensure_project", "ensure_change", "record_task_progress",
    "record_handoff", "record_handoff_invocation", "risks_blockers", "decision_required", "next_action",
]
values = {key: "value" for key in keys}
values.update({
    "schema": "pegasus-specialist-result/v2", "status": "completed", "specialist_agent": "sdd-tasks",
    "artifact_path": "docs/pegasus/changes/mobile/tasks.md",
    "final_tasks_revision": "sha256:artifact", "persistence_tasks_revision": "sha256:artifact",
    "post_persistence_edits": "none", "chain_strategy": "pending",
    "strategy_decision_evidence": "none", "size_exception_approval_evidence": "none",
    "ensure_project": "not needed", "ensure_change": "not needed",
    "record_task_progress": "succeeded", "record_handoff": "succeeded",
})

def canonical(data: dict[str, str]) -> str:
    raw = json.dumps(data, ensure_ascii=True, separators=(",", ":"))
    return raw.replace("/", "\\u002f")

serialized = canonical(values)
revision = "sha256:" + hashlib.sha256((serialized + "\n").encode()).hexdigest()
block = f"{begin}\nSpecialist result block revision: {revision}\n{serialized}\n{end}"

def validate_block(text: str) -> str | None:
    if legacy_begin in text or legacy_end in text or text.count(begin) != 1 or text.count(end) != 1:
        return None
    lines = text.splitlines()
    if len(lines) != 4 or lines[0] != begin or lines[3] != end:
        return None
    if not lines[1].startswith("Specialist result block revision: sha256:"):
        return None
    serialized_line = lines[2]
    if "/" in serialized_line:
        return None
    expected = "sha256:" + hashlib.sha256((serialized_line + "\n").encode()).hexdigest()
    if lines[1] != f"Specialist result block revision: {expected}":
        return None
    pairs = []
    try:
        parsed = json.loads(serialized_line, object_pairs_hook=lambda value: pairs.extend(value) or dict(value))
    except (json.JSONDecodeError, UnicodeDecodeError):
        return None
    if [key for key, _ in pairs] != keys or len({key for key, _ in pairs}) != len(keys):
        return None
    if not all(isinstance(value, str) and not any(0xD800 <= ord(char) <= 0xDFFF for char in value) for value in parsed.values()):
        return None
    if canonical(parsed) != serialized_line:
        return None
    if parsed.get("schema") != "pegasus-specialist-result/v2" or parsed.get("artifact_path") != "docs/pegasus/changes/mobile/tasks.md":
        return None
    if parsed.get("final_tasks_revision") != parsed.get("persistence_tasks_revision"):
        return None
    return text

assert validate_block(block) == block
assert "docs/pegasus/changes/mobile/tasks.md" not in block
rendered_copy = block.replace("docs/pegasus/changes/mobile/tasks.md", "tasks.md")
assert rendered_copy == block and validate_block(rendered_copy) == block
assert validate_block(block.replace("docs\\u002fpegasus\\u002fchanges\\u002fmobile\\u002ftasks.md", "tasks.md")) is None
assert validate_block(block.replace('"work_unit_count":"value",', "")) is None
assert validate_block(block.replace('"work_unit_count":"value","assigned_scope":"value"', '"assigned_scope":"value","work_unit_count":"value"')) is None
assert validate_block(block.replace('"work_unit_count":"value"', '"work_unit_count":"value","work_unit_count":"value"')) is None
assert validate_block(block.replace(begin + "\n", "")) is None
assert validate_block(block + "\n" + block) is None
assert validate_block(block + "\nartifact_path: docs/pegasus/changes/mobile/tasks.md") is None
assert validate_block(block.replace("Specialist result block revision: sha256:", "Specialist result block revision: sha256:0")) is None
assert validate_block(block.replace('docs\\u002fpegasus', 'docs\\/pegasus')) is None
assert validate_block(block.replace('docs\\u002fpegasus', 'docs\\u02Gfpegasus')) is None
legacy = block.replace(begin, legacy_begin).replace(end, legacy_end)
assert validate_block(legacy) is None
assert validate_block(block + "\n" + legacy) is None

def orchestrator_transport(specialist_result: str) -> str:
    validated = validate_block(specialist_result)
    return validated if validated is not None else "Status: blocked\nIntegrity gate: invalid specialist result block"

assert orchestrator_transport(block).encode() == block.encode()
assert orchestrator_transport(block.replace('"work_unit_count":"value"', '"work_unit_count":"changed"')).startswith("Status: blocked")
for required in (begin, end, "Specialist result block revision", "canonical JSON", "\\u002f", "byte-for-byte", "do not ask strategy or launch apply"):
    assert required in specialist + orchestrator, required
PY
"$PYTHON_BIN" - "$target/.github/copilot-instructions.md" "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" <<'PY'
import sys
from pathlib import Path

active_guidance = "\n".join(Path(path).read_text() for path in sys.argv[1:])
legacy_permissions = (
    "The orchestrator summarizes this envelope",
    "It MUST summarize the specialist envelope",
)

def permits_summarize_only(text: str) -> bool:
    return any(permission in text for permission in legacy_permissions)

assert not permits_summarize_only(active_guidance)
negative_fixture = active_guidance + "\nIt MUST summarize the specialist envelope without claiming direct artifact validation."
assert permits_summarize_only(negative_fixture)
assert "Lossy narrative summarization MUST NOT substitute for complete envelope reproduction" in active_guidance
PY
"$PYTHON_BIN" - "$target/docs/pegasus/design.md" <<'PY'
import sys
from pathlib import Path

template = Path(sys.argv[1]).read_text()

def validate_risk_coverage(proposal_risks, design_risks, testing_rows, na_rationales):
    missing_design = [risk for risk in proposal_risks if risk not in design_risks]
    missing_test = [
        risk for risk in proposal_risks
        if risk not in testing_rows and not na_rationales.get(risk)
    ]
    return missing_design, missing_test

mobile_risk = "Mobile rendering performance may miss the target frame rate"
proposal = [mobile_risk, "Offline state may be lost"]
design = {mobile_risk: "profile render loop", "Offline state may be lost": "durable local state"}
tests = {mobile_risk: "measure frame time on target mobile device"}
na = {"Offline state may be lost": "Persistence recovery is verified by integration behavior, not performance measurement"}
assert validate_risk_coverage(proposal, design, tests, na) == ([], [])

missing_design, missing_test = validate_risk_coverage(proposal, {proposal[1]: design[proposal[1]]}, {}, na)
assert missing_design == [mobile_risk]
assert missing_test == [mobile_risk]
assert "## Proposal Risk Coverage" in template
assert "Mobile rendering performance" in template
PY
"$PYTHON_BIN" - "$target/.github/agents/sdd-design.agent.md" "$target/docs/pegasus/design.md" <<'PY'
import sys
from pathlib import Path

guidance = Path(sys.argv[1]).read_text()
template = Path(sys.argv[2]).read_text()
required = {
    "Choice / topic", "Status", "Owner", "Impact", "Next step", "Needed-by gate",
    "Invariant architecture", "Why non-blocking", "Evidence / source",
}
header = next(line for line in template.splitlines() if line.startswith("| Choice / topic |"))
assert required <= set(cell.strip() for cell in header.strip("|").split("|"))
assert "| None | N/A |" in template
assert guidance.index("Before marker validation, language validation, or persistence") < guidance.index("## Managed artifact")
assert guidance.index("Before marker validation, language validation, or persistence") < guidance.index("Before completed-path Pegasus Memory artifact persistence")
assert "The final response uses the exact `Deferred technical choices:` label" in guidance

def spanish_gate_issues(text: str) -> set[str]:
    import re

    issues = set()
    for heading in ("Tradeoffs", "Costos y compromisos", "Compensaciones", "Decisiones y costos y compromisos"):
        if f"## {heading}" in text:
            issues.add(heading)
    if re.search(r"(?i)\bgreenfield\s*/\s*no implementation evidence\b", text):
        issues.add("English greenfield classification")
    for term in ("Contexto MCP", "Memoria MCP", "Memoria Pegasus"):
        if term in text:
            issues.add(term)
    for match in re.finditer(r"(?<![\w-])MCP(?![\w-])", text):
        allowed_protocol_phrase = text[max(0, match.start() - len("protocolo ")):match.end()]
        if allowed_protocol_phrase != "protocolo MCP":
            issues.add("standalone MCP")
    return issues

assert spanish_gate_issues("## Tradeoffs\nGreenfield/no implementation evidence\nContexto MCP\nMCP") == {
    "Tradeoffs", "English greenfield classification", "Contexto MCP", "standalone MCP",
}
assert spanish_gate_issues("Greenfield / no implementation evidence") == {
    "English greenfield classification",
}
assert spanish_gate_issues("greenfield/no implementation evidence") == {
    "English greenfield classification",
}
assert spanish_gate_issues("protocolo MCP\nMCP para la persistencia") == {
    "standalone MCP",
}
assert not spanish_gate_issues("protocolo MCP")
assert not spanish_gate_issues("pegasus-memory-mcp")
assert not spanish_gate_issues(
    "## Decisiones y compensaciones\nGreenfield / sin evidencia de implementación\n"
    "Pegasus Memory\npegasus-memory-mcp\nprotocolo MCP\n`record_artifact`\n/path/to/file"
)
for legacy_heading in ("## Costos y compromisos", "## Compensaciones", "## Decisiones y costos y compromisos"):
    assert spanish_gate_issues(legacy_heading)
assert not spanish_gate_issues("## Decisiones y compensaciones")
assert "Decisiones y compensaciones" in guidance
assert "Pegasus Memory" in template and "Pegasus Memory context" in template
assert "Greenfield / no implementation evidence" in template
assert "Greenfield / sin evidencia de implementación" in template
PY
"$PYTHON_BIN" - "$target/docs/pegasus" <<'PY'
import sys
from pathlib import Path

root = Path(sys.argv[1])
templates = {name: (root / f"{name}.md").read_text() for name in (
    "prd", "proposal", "spec", "design", "tasks", "apply-progress", "verify"
)}
for name, text in templates.items():
    assert "English" in text, name
    assert "explicitly names" in text, name
    assert "language gate" in text, name
    assert "dominant approved-source language" in text or "source language" in text, name

# Spanish remains a supported explicit override without becoming default scaffolding.
for name in ("prd", "proposal"):
    assert "Validation mapping for an explicit Spanish override only" in templates[name]
    assert "`Created:` becomes `Creado:`" in templates[name]
assert "These Spanish labels are fixtures, not default template content" in templates["spec"]
assert "These Spanish values are validation fixtures, not defaults" in templates["design"]
assert "| None | N/A |" in templates["design"]
PY
"$PYTHON_BIN" - "$target" <<'PY'
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])
surfaces = [root / "AGENTS.md"]
surfaces.extend((root / ".github").rglob("*.md"))
surfaces.extend((root / ".cursor").rglob("*.mdc"))
operational_root = re.compile(r"docs/pegasus/(?:proposal|spec|design|tasks|apply-progress|verify)\.md")
phase_name = re.compile(r"^(?:prd|proposal|spec|design|tasks|apply-progress|verify)\.md$")
for path in surfaces:
    for number, line in enumerate(path.read_text().splitlines(), start=1):
        if operational_root.search(line):
            assert "canonical template" in line, f"root operational phase path: {path}:{number}: {line}"

        # A root path followed by bare sibling filenames is shorthand for root
        # phase paths and must not bypass the change-scoped path requirement.
        spans = re.findall(r"`([^`]+)`", line)
        root_phase_seen = False
        for span in spans:
            if re.fullmatch(r"docs/pegasus/(?:prd|proposal|spec|design|tasks|apply-progress|verify)\.md", span):
                root_phase_seen = True
                continue
            if root_phase_seen and phase_name.fullmatch(span):
                raise AssertionError(f"shorthand root phase sibling: {path}:{number}: {line}")

required = "docs/pegasus/changes/<change-id>/"
for name in (
    ".github/agents/sdd-tasks.agent.md",
    ".github/references/phases/apply.md",
    ".github/references/phases/verify.md",
    ".github/prompts/sdd-phases.prompt.md",
    ".github/prompts/handoff.prompt.md",
    ".cursor/rules/pegasus-workflow.mdc",
    ".cursor/rules/pegasus-memory.mdc",
):
    assert required in (root / name).read_text(), name

copilot = (root / ".github/copilot-instructions.md").read_text()
for phase in ("prd", "proposal", "spec", "design", "tasks", "apply-progress", "verify"):
    assert f"docs/pegasus/changes/<change-id>/{phase}.md" in copilot, phase
assert "Root phase files are canonical templates only" in copilot
assert "Then read `docs/pegasus/prd.md`, `proposal.md`" not in copilot
PY
"$PYTHON_BIN" - "$ROOT/templates/cursor-global/pegasus-global.mdc" "$ROOT/templates/copilot-global/agents/pegasus-global-orchestrator.agent.md" <<'PY'
import sys
from pathlib import Path

cursor, copilot = (Path(raw).read_text() for raw in sys.argv[1:])
assert "docs/pegasus/changes/<change-id>/" in cursor
assert "Update local Markdown memory" not in cursor
assert "docs/pegasus/changes/<change-id>/" in copilot
PY
for global_language_file in \
  "$copilot_install_xdg/pegasus-ia/copilot/agents/pegasus-global-orchestrator.agent.md" \
  "$copilot_install_xdg/pegasus-ia/copilot/instructions/pegasus-global.instructions.md" \
  "$copilot_install_xdg/pegasus-ia/copilot/prompts/pegasus-start.prompt.md"; do
  assert_file_contains "$global_language_file" "English"
done
assert_file_contains "$copilot_install_xdg/pegasus-ia/copilot/agents/pegasus-global-orchestrator.agent.md" 'Artifact language: <language>'
if grep -R -E "otherwise use the dominant language|dominant approved source language|dominant approved PRD/proposal language" \
  "$target/.github" >/dev/null; then
  printf 'rendered operational guidance retains legacy artifact-language inference\n' >&2
  exit 1
fi
"$PYTHON_BIN" - "$ROOT/templates/harness/docs/pegasus/design.md" <<'PY'
import sys
from pathlib import Path

lines = Path(sys.argv[1]).read_text().splitlines()
assert lines[0] == "<!-- pegasus-harness:start path=docs/pegasus/changes/<change-id>/design.md ownership=full-file -->"
assert lines[-1] == "<!-- pegasus-harness:end path=docs/pegasus/changes/<change-id>/design.md -->"
PY
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" "Create only the current change technical design from its approved in-file PRD, proposal, and spec"
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" 'Before design, read the current change'"'"'s approved in-file PRD, proposal, and spec'
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" 'For design closure, use Pegasus Memory/`pegasus-memory-mcp` terminology'
assert_file_contains "$target/.github/copilot-instructions.md" "Before design, require current-change in-file approval for PRD, proposal, and spec"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" "Design requires approved isolated evidence and technical context"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" "Design reconciles technical gaps and closes truthfully"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" '`None` / `Ninguna` MUST be invalid'
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" 'exact structured labels `Artifact language:`, `Language gate:`, `Deferred technical choices:`'
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" 'exact canonical heading `Decisiones y compensaciones`'
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" 'docs/pegasus/changes/<change-id>/design.md'
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" 'record_artifact` MUST be `not needed` because no design artifact was written'
assert_file_contains "$target/docs/pegasus/design.md" "Blocking gaps prohibit design artifact writing, artifact finalization, and \`record_artifact\`"
assert_file_contains "$target/docs/pegasus/design.md" "minimal blocked control-state persistence: \`ensure_project\`/\`ensure_change\` as needed, \`record_observation\`, \`record_task_progress\` with status \`blocked\`, and \`record_handoff\`"
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" 'MUST prohibit design artifact writing, artifact finalization, and `record_artifact`, while allowing and requiring minimal blocked control-state persistence'
assert_file_contains "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md" '`ensure_project`/`ensure_change` as needed, `record_observation`, phase `design` `record_task_progress` with status `blocked`, and `record_handoff`'
if grep -Fq 'Blocking gaps stop before writing/finalization/persistence' "$ROOT/templates/harness/docs/pegasus/design.md"; then
  printf 'canonical design template contains generic blocked-persistence wording\n' >&2
  exit 1
fi
if grep -Fq 'stop before writing, finalizing, or Pegasus Memory persistence' "$ROOT/openspec/specs/pegasus-harness-bootstrap/spec.md"; then
  printf 'stable spec contains generic blocked-persistence wording\n' >&2
  exit 1
fi
"$PYTHON_BIN" - "$target/.github/agents/sdd-tasks.agent.md" "$apply_reference" "$verify_reference" "$target/.github/prompts/sdd-phases.prompt.md" <<'PY'
import sys
from pathlib import Path

for raw in sys.argv[1:]:
    text = Path(raw).read_text()
    assert "docs/pegasus/changes/<change-id>/design.md" in text, raw
    assert "docs/pegasus/design.md" not in text, raw
PY
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
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" 'Before invoking any git command, first check whether the workspace root contains a `.git` directory.'
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" 'If `.git` is absent, never attempt `git diff`, `git status`, `git log`, or any other git validation; do not try and fall back.'
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" 'include a small MCP persistence summary with one line each for `ensure_project`, `ensure_change`, `record_artifact`, and `record_observation`'
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" 'marking every call as `succeeded`, `not needed`, or `failed: <reason>`'
assert_file_contains "$target/.github/copilot-instructions.md" 'before any git command first check for `.git` and never run `git diff`, `git status`, or other git validation in non-git workspaces'
assert_file_contains "$target/.github/copilot-instructions.md" 'include a small MCP persistence summary marking `ensure_project`, `ensure_change`, `record_artifact`, and `record_observation` as `succeeded`, `not needed`, or `failed: <reason>`'
assert_file_contains "$target/.github/instructions/pegasus-workflow.instructions.md" 'before any git command first check for `.git` and never run `git diff`, `git status`, or other git validation in non-git workspaces'
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" 'For PRD closure, include a small MCP persistence summary with one line each for `ensure_project`, `ensure_change`, `record_artifact`, and `record_observation`'
assert_file_contains "$target/.github/instructions/pegasus-memory.instructions.md" 'For proposal closure, the final response MUST contain this exact block even when MCP is unavailable'
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" 'do not mention git validation as attempted'
assert_file_contains "$target/.github/agents/pegasus-orchestrator.agent.md" 'The only acceptable database mutation is an explicit Pegasus Memory schema migration performed by Pegasus Memory itself'
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
if conflict_output="$($PYTHON_BIN "$CLI" --project-name sample-project --target-path "$target" 2>&1)"; then
  printf 'normal bootstrap should refuse a manifest-backed workspace\n' >&2
  exit 1
fi
case "$conflict_output" in
  *"existing Pegasus workspace manifest found; normal bootstrap will not replace lifecycle metadata."*"Run --sync-workspace --dry-run, then --sync-workspace."*) ;;
  *) printf 'expected manifest-backed bootstrap refusal to recommend safe sync\n' >&2; exit 1 ;;
esac
assert_file_contains "$target/AGENTS.md" "user content"
assert_file_contains "$target/docs/pegasus/apply-progress.md" "custom apply progress"
assert_file_contains "$target/.github/copilot-instructions.md" "custom copilot instructions"
[ ! -e "$target/.github/agents/doc-designer.agent.md" ] || { printf 'manifest-backed bootstrap unexpectedly wrote a missing harness file\n' >&2; exit 1; }
"$PYTHON_BIN" - "$target/.pegasus-bootstrap-ia/manifest.json" <<'PY'
import json
import sys
from pathlib import Path

manifest = json.loads(Path(sys.argv[1]).read_text())
assert manifest["install"]["skipped_conflicts"] == []
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

non_pegasus_target="$TMP/non-pegasus-conflicts"
mkdir -p "$non_pegasus_target"
printf 'non-Pegasus content\n' > "$non_pegasus_target/AGENTS.md"
non_pegasus_conflict_output="$($PYTHON_BIN "$CLI" --project-name non-pegasus --target-path "$non_pegasus_target")"
case "$non_pegasus_conflict_output" in
  *"Conflicts (skipped unless --force):"*"$non_pegasus_target/AGENTS.md"*"Existing non-Pegasus conflicts were preserved."*"Use --force only to intentionally replace known conflicting harness files."*) ;;
  *) printf 'expected non-Pegasus conflicts to retain an explicit, guarded force option\n' >&2; exit 1 ;;
esac
case "$non_pegasus_conflict_output" in
  *"--sync-workspace --dry-run"*) printf 'non-Pegasus conflict output should not recommend workspace sync\n' >&2; exit 1 ;;
  *) ;;
esac
assert_file_contains "$non_pegasus_target/AGENTS.md" 'non-Pegasus content'

recovery_target="$TMP/recovery-target"
printf 'yes\n' | "$PYTHON_BIN" "$CLI" --project-name recovery-project --target-path "$recovery_target" >/dev/null
printf 'user PRD artifact\n' > "$recovery_target/docs/pegasus/prd.md"
printf 'user MCP config\n' > "$recovery_target/.vscode/mcp.json"
cat > "$recovery_target/.github/agents/sdd-spec.agent.md" <<'MARKERS'
<!-- pegasus-harness:start path=.github/agents/sdd-spec.agent.md ownership=full-file -->
STALE PEGASUS SPEC AGENT
<!-- pegasus-harness:end path=.github/agents/sdd-spec.agent.md -->
MARKERS
"$PYTHON_BIN" - "$recovery_target/.pegasus-bootstrap-ia/manifest.json" <<'PY'
import json
import sys
from pathlib import Path

manifest_path = Path(sys.argv[1])
manifest = json.loads(manifest_path.read_text())
manifest["template_version"] = "1"
manifest.pop("package_version", None)
manifest["install"]["files"] = []
manifest["ownership"]["files"] = []
manifest["update"] = {"last_run_at": "historic", "overwrite_conflicts": ["historic"]}
manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")
PY
cp "$recovery_target/.pegasus-bootstrap-ia/manifest.json" "$TMP/recovery-manifest-before.json"
if recovery_bootstrap_output="$($PYTHON_BIN "$CLI" --project-name recovery-project --target-path "$recovery_target" 2>&1)"; then
  printf 'normal bootstrap should not rewrite an empty manifest-backed workspace\n' >&2
  exit 1
fi
case "$recovery_bootstrap_output" in
  *"normal bootstrap will not replace lifecycle metadata"*) ;;
  *) printf 'expected empty-manifest bootstrap refusal\n' >&2; exit 1 ;;
esac
cmp "$TMP/recovery-manifest-before.json" "$recovery_target/.pegasus-bootstrap-ia/manifest.json" || { printf 'normal bootstrap rewrote historical manifest metadata\n' >&2; exit 1; }
recovery_dry_output="$($PYTHON_BIN "$CLI" --target-path "$recovery_target" --sync-workspace --dry-run)"
case "$recovery_dry_output" in
    *"Installed CLI version: 0.6.9"*"Source template version: 0.6.9"*"Manifest template version: 1"*"Recovered managed files (will update):"*"$recovery_target/.github/agents/sdd-spec.agent.md"*"Dry run only; no files were written."*) ;;
  *) printf 'expected empty-manifest dry-run recovery and version evidence\n' >&2; exit 1 ;;
esac
assert_file_contains "$recovery_target/.github/agents/sdd-spec.agent.md" 'STALE PEGASUS SPEC AGENT'
assert_file_contains "$recovery_target/docs/pegasus/prd.md" 'user PRD artifact'
assert_file_contains "$recovery_target/.vscode/mcp.json" 'user MCP config'
recovery_sync_output="$($PYTHON_BIN "$CLI" --target-path "$recovery_target" --sync-workspace)"
case "$recovery_sync_output" in
  *"Completed Pegasus workspace sync."*"Updated: $recovery_target/.github/agents/sdd-spec.agent.md"*"Recovered managed ownership: $recovery_target/.github/agents/sdd-spec.agent.md"*) ;;
  *) printf 'expected recovered managed agent to be updated and reported\n' >&2; exit 1 ;;
esac
assert_file_contains "$recovery_target/.github/agents/sdd-spec.agent.md" 'Pegasus Memory closure contract'
assert_file_contains "$recovery_target/docs/pegasus/prd.md" 'user PRD artifact'
assert_file_contains "$recovery_target/.vscode/mcp.json" 'user MCP config'
"$PYTHON_BIN" - "$recovery_target/.pegasus-bootstrap-ia/manifest.json" <<'PY'
import json
import sys
from pathlib import Path

manifest = json.loads(Path(sys.argv[1]).read_text())
records = {record["path"]: record for record in manifest["ownership"]["files"]}
assert manifest["template_version"] == "0.6.9"
assert manifest["package_version"] == "0.6.9"
assert records[".github/agents/sdd-spec.agent.md"]["action"] == "recovered"
assert not any(path.startswith("docs/pegasus/") for path in records)
PY
recovery_repeat_output="$($PYTHON_BIN "$CLI" --target-path "$recovery_target" --sync-workspace)"
case "$recovery_repeat_output" in
  *"Recovered managed ownership:"*) printf 'ownership recovery should be idempotent\n' >&2; exit 1 ;;
  *"Completed Pegasus workspace sync."*) ;;
  *) printf 'expected idempotent recovery sync completion\n' >&2; exit 1 ;;
esac

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
memory_home="$TMP/memory-home"
mkdir -p "$memory_home/.local/share/pegasus-memory-mcp"
printf 'existing memory db\n' > "$memory_home/.local/share/pegasus-memory-mcp/memory.db"
sync_memory_home_output="$(HOME="$memory_home" "$PYTHON_BIN" "$CLI" --target-path "$sync_target" --sync-workspace)"
case "$sync_memory_home_output" in
  *"Pegasus workspace sync plan"*"Completed Pegasus workspace sync."*) ;;
  *) printf 'expected workspace sync with external memory HOME to succeed\n' >&2; exit 1 ;;
esac
assert_file_contains "$memory_home/.local/share/pegasus-memory-mcp/memory.db" 'existing memory db'
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
[ -f "$uninstall_target/docs/pegasus/prd.md" ] || { printf 'workspace uninstall removed generated PRD artifact\n' >&2; exit 1; }
[ -f "$uninstall_target/docs/pegasus/proposal.md" ] || { printf 'workspace uninstall removed generated proposal artifact\n' >&2; exit 1; }
[ -f "$uninstall_target/docs/pegasus/user-note.md" ] || { printf 'workspace uninstall removed user docs file\n' >&2; exit 1; }
[ -f "$uninstall_target/.github/agents/user.agent.md" ] || { printf 'workspace uninstall removed user agent file\n' >&2; exit 1; }

fake_bin="$TMP/fake-bin"
mkdir -p "$fake_bin"
cat > "$fake_bin/pegasus-memory-mcp" <<'SH'
#!/usr/bin/env sh
printf '%s\n' "$*" >> "$PEGASUS_FAKE_MEMORY_LOG"
SH
chmod +x "$fake_bin/pegasus-memory-mcp"

memory_dry_target="$TMP/memory-dry-uninstall-target"
printf 'yes\n' | "$PYTHON_BIN" "$CLI" --project-name memory-dry-project --target-path "$memory_dry_target" >/dev/null
memory_dry_log="$TMP/memory-dry.log"
memory_dry_output="$(PEGASUS_FAKE_MEMORY_LOG="$memory_dry_log" PATH="$fake_bin:$PATH" "$PYTHON_BIN" "$CLI" --target-path "$memory_dry_target" --uninstall --purge-memory --dry-run)"
case "$memory_dry_output" in
  *"Pegasus Memory total purge (delegated):"*"Command: pegasus-memory-mcp purge --all --dry-run"*"Dry run only; no files were removed."*) ;;
  *) printf 'expected uninstall memory purge dry-run delegated command plan\n' >&2; exit 1 ;;
esac
[ -f "$memory_dry_target/AGENTS.md" ] || { printf 'memory cleanup dry-run removed workspace file\n' >&2; exit 1; }
[ ! -e "$memory_dry_log" ] || { printf 'memory cleanup dry-run executed external CLI\n' >&2; exit 1; }

missing_manifest_dry_target="$TMP/missing-manifest-memory-dry-target"
mkdir -p "$missing_manifest_dry_target"
printf 'workspace user file\n' > "$missing_manifest_dry_target/user-file.txt"
missing_manifest_dry_log="$TMP/missing-manifest-memory-dry.log"
missing_manifest_dry_output="$(PEGASUS_FAKE_MEMORY_LOG="$missing_manifest_dry_log" PATH="$fake_bin:$PATH" "$PYTHON_BIN" "$CLI" --target-path "$missing_manifest_dry_target" --uninstall --purge-memory --dry-run)"
case "$missing_manifest_dry_output" in
  *"Workspace uninstall skipped:"*"No workspace manifest was found: $missing_manifest_dry_target/.pegasus-bootstrap-ia/manifest.json"*"Pegasus IA managed workspace assets cannot be planned or removed safely without the manifest."*"Pegasus Memory total purge (delegated):"*"Command: pegasus-memory-mcp purge --all --dry-run"*"Dry run only; no files were removed."*) ;;
  *) printf 'expected missing-manifest purge dry-run to skip workspace planning and show delegated purge command\n' >&2; exit 1 ;;
esac
[ -f "$missing_manifest_dry_target/user-file.txt" ] || { printf 'missing-manifest purge dry-run removed workspace file\n' >&2; exit 1; }
[ ! -e "$missing_manifest_dry_log" ] || { printf 'missing-manifest purge dry-run executed external CLI\n' >&2; exit 1; }

missing_manifest_real_target="$TMP/missing-manifest-memory-real-target"
mkdir -p "$missing_manifest_real_target/.github"
printf 'workspace user file\n' > "$missing_manifest_real_target/user-file.txt"
printf 'unowned agents\n' > "$missing_manifest_real_target/AGENTS.md"
missing_manifest_real_log="$TMP/missing-manifest-memory-real.log"
missing_manifest_real_output="$(PEGASUS_FAKE_MEMORY_LOG="$missing_manifest_real_log" PATH="$fake_bin:$PATH" "$PYTHON_BIN" "$CLI" --target-path "$missing_manifest_real_target" --uninstall --purge-memory)"
case "$missing_manifest_real_output" in
  *"Workspace uninstall skipped:"*"Skipped Pegasus workspace uninstall because the workspace manifest was not found."*"No workspace files were removed by Pegasus IA."*"Completed delegated memory cleanup: pegasus-memory-mcp purge --all --yes-i-understand-this-deletes-data"*) ;;
  *) printf 'expected missing-manifest real purge to skip workspace removal and run delegated purge\n' >&2; exit 1 ;;
esac
assert_file_contains "$missing_manifest_real_log" 'purge --all --yes-i-understand-this-deletes-data'
assert_file_contains "$missing_manifest_real_target/user-file.txt" 'workspace user file'
assert_file_contains "$missing_manifest_real_target/AGENTS.md" 'unowned agents'

fake_node_bin="$TMP/fake-node-bin"
mkdir -p "$fake_node_bin"
cat > "$fake_node_bin/node" <<'SH'
#!/bin/sh
printf 'cwd=%s args=%s\n' "$PWD" "$*" >> "$PEGASUS_FAKE_NODE_LOG"
SH
chmod +x "$fake_node_bin/node"

mcp_discovery_target="$TMP/mcp-discovery-target"
mkdir -p "$mcp_discovery_target/.vscode" "$TMP/fake-memory-root/dist/bin"
fake_memory_script="$TMP/fake-memory-root/dist/bin/pegasus-memory-mcp.js"
printf '// fake memory cli\n' > "$fake_memory_script"
cat > "$mcp_discovery_target/.vscode/mcp.json" <<JSON
{
  "servers": {
    "pegasus-memory-mcp": {
      "command": "node",
      "cwd": "$TMP/fake-memory-root",
      "args": ["$fake_memory_script"]
    }
  }
}
JSON
mcp_discovery_dry_log="$TMP/mcp-discovery-dry.log"
mcp_discovery_dry_output="$(PEGASUS_FAKE_NODE_LOG="$mcp_discovery_dry_log" PATH="$fake_node_bin" "$VENV/bin/python" "$CLI" --target-path "$mcp_discovery_target" --uninstall --purge-memory --dry-run)"
case "$mcp_discovery_dry_output" in
  *"Workspace uninstall skipped:"*"Pegasus Memory total purge (delegated):"*"Command: node $fake_memory_script purge --all --dry-run"*"Cwd: $TMP/fake-memory-root"*"Dry run only; no files were removed."*) ;;
  *) printf 'expected mcp.json discovery dry-run to show resolved node command and cwd\n' >&2; exit 1 ;;
esac
[ ! -e "$mcp_discovery_dry_log" ] || { printf 'mcp.json discovery dry-run executed node\n' >&2; exit 1; }

mcp_discovery_real_log="$TMP/mcp-discovery-real.log"
mcp_discovery_real_output="$(PEGASUS_FAKE_NODE_LOG="$mcp_discovery_real_log" PATH="$fake_node_bin" "$VENV/bin/python" "$CLI" --target-path "$mcp_discovery_target" --uninstall --purge-memory)"
case "$mcp_discovery_real_output" in
  *"Skipped Pegasus workspace uninstall because the workspace manifest was not found."*"Completed delegated memory cleanup: node $fake_memory_script purge --all --yes-i-understand-this-deletes-data"*) ;;
  *) printf 'expected mcp.json discovery real purge to execute resolved node command\n' >&2; exit 1 ;;
esac
assert_file_contains "$mcp_discovery_real_log" "cwd=$TMP/fake-memory-root args=$fake_memory_script purge --all --yes-i-understand-this-deletes-data"

override_cli="$TMP/override-memory-cli"
cat > "$override_cli" <<'SH'
#!/bin/sh
printf '%s\n' "$*" >> "$PEGASUS_OVERRIDE_MEMORY_LOG"
SH
chmod +x "$override_cli"
override_target="$TMP/override-memory-target"
printf 'yes\n' | "$PYTHON_BIN" "$CLI" --project-name override-memory --target-path "$override_target" >/dev/null
override_log="$TMP/override-memory.log"
override_output="$(PEGASUS_OVERRIDE_MEMORY_LOG="$override_log" PATH="/usr/bin:/bin" "$VENV/bin/python" "$CLI" --target-path "$override_target" --uninstall --reset-memory-project --memory-cli-command "$override_cli")"
case "$override_output" in
  *"Completed delegated memory cleanup: $override_cli reset --project override-memory --yes"*) ;;
  *) printf 'expected explicit memory CLI override to run absolute command\n' >&2; exit 1 ;;
esac
assert_file_contains "$override_log" 'reset --project override-memory --yes'

override_js_target="$TMP/override-js-memory-target"
mkdir -p "$override_js_target"
override_js="$TMP/override-memory.js"
printf '// fake js entrypoint\n' > "$override_js"
override_js_dry_output="$(PATH="$fake_node_bin" "$VENV/bin/python" "$CLI" --target-path "$override_js_target" --uninstall --purge-memory --memory-cli-command "$override_js" --dry-run)"
case "$override_js_dry_output" in
  *"Pegasus Memory total purge (delegated):"*"Command: node $override_js purge --all --dry-run"*) ;;
  *) printf 'expected .js memory CLI override to be wrapped with node in dry-run\n' >&2; exit 1 ;;
esac

memory_reset_target="$TMP/memory-reset-uninstall-target"
printf 'yes\n' | "$PYTHON_BIN" "$CLI" --project-name memory-reset-project --target-path "$memory_reset_target" >/dev/null
memory_reset_home="$TMP/memory-reset-home"
mkdir -p "$memory_reset_home/.local/share/pegasus-memory-mcp"
printf 'existing memory db\n' > "$memory_reset_home/.local/share/pegasus-memory-mcp/memory.db"
memory_reset_log="$TMP/memory-reset.log"
memory_reset_output="$(HOME="$memory_reset_home" PEGASUS_FAKE_MEMORY_LOG="$memory_reset_log" PATH="$fake_bin:$PATH" "$PYTHON_BIN" "$CLI" --target-path "$memory_reset_target" --uninstall --reset-memory-project)"
case "$memory_reset_output" in
  *"Completed Pegasus workspace uninstall."*"Completed delegated memory cleanup: pegasus-memory-mcp reset --project memory-reset-project --yes"*) ;;
  *) printf 'expected workspace uninstall with delegated project memory reset\n' >&2; exit 1 ;;
esac
assert_file_contains "$memory_reset_log" 'reset --project memory-reset-project --yes'
assert_file_contains "$memory_reset_home/.local/share/pegasus-memory-mcp/memory.db" 'existing memory db'

if "$PYTHON_BIN" "$CLI" --target-path "$memory_dry_target" --uninstall --reset-memory-project --purge-memory --dry-run >/dev/null 2>&1; then
  printf 'expected reset and purge memory flags to be mutually exclusive\n' >&2
  exit 1
fi

memory_missing_target="$TMP/memory-missing-cli-target"
printf 'yes\n' | "$PYTHON_BIN" "$CLI" --project-name memory-missing-cli --target-path "$memory_missing_target" >/dev/null
if memory_missing_output="$(PATH="/nonexistent" "$VENV/bin/python" "$CLI" --target-path "$memory_missing_target" --uninstall --reset-memory-project 2>&1)"; then
  printf 'expected requested memory cleanup to require pegasus-memory-mcp CLI\n' >&2
  exit 1
fi
case "$memory_missing_output" in
  *"pegasus-memory-mcp is required for requested memory cleanup"*) ;;
  *) printf 'expected clear missing pegasus-memory-mcp error\n' >&2; exit 1 ;;
esac
[ -f "$memory_missing_target/AGENTS.md" ] || { printf 'missing memory CLI failure removed workspace file\n' >&2; exit 1; }

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
assert_file_contains "$global_xdg/Cursor/User/rules/pegasus-global.mdc" "never infer an override from chat, persona, source, or prior artifact language"
assert_file_contains "$global_xdg/Cursor/User/rules/pegasus-global.mdc" 'record `Artifact language: <language>`'
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
