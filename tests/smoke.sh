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
  ".cursor/rules/pegasus-memory.mdc"
  ".cursor/rules/pegasus-workflow.mdc"
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

default_plan="$($PYTHON_BIN "$CLI" --project-name default-project --dry-run)"
case "$default_plan" in
  *"Target: /var/www/html/personal/default-project"*) ;;
  *) printf 'expected default target path in dry-run output\n' >&2; exit 1 ;;
esac

dry_target="$TMP/dry-run-project"
"$PYTHON_BIN" "$CLI" --project-name dry-run-project --target-path "$dry_target" --dry-run >/dev/null
[ ! -e "$dry_target" ] || { printf 'dry-run wrote files\n' >&2; exit 1; }

default_home="$TMP/default-home"
default_xdg="$TMP/default-xdg"
default_target="$TMP/default-no-global"
mkdir -p "$default_home" "$default_xdg"
HOME="$default_home" XDG_CONFIG_HOME="$default_xdg" "$PYTHON_BIN" "$CLI" --project-name default-no-global --target-path "$default_target" >/dev/null
[ -f "$default_target/AGENTS.md" ] || { printf 'default run did not create target harness\n' >&2; exit 1; }
[ ! -e "$default_xdg/Cursor" ] || { printf 'default run touched XDG Cursor config\n' >&2; exit 1; }
[ ! -e "$default_home/.config/Cursor" ] || { printf 'default run touched HOME Cursor config\n' >&2; exit 1; }
[ ! -e "$default_home/.cursor" ] || { printf 'default run touched legacy Cursor config\n' >&2; exit 1; }

target="$TMP/sample-project"
"$PYTHON_BIN" "$CLI" --project-name sample-project --target-path "$target" >/dev/null
for file in "${expected_files[@]}"; do
  [ -f "$target/$file" ] || { printf 'expected generated file %s\n' "$file" >&2; exit 1; }
done
assert_file_contains "$target/AGENTS.md" "sample-project"
assert_file_contains "$target/AGENTS.md" "$target"
assert_file_contains "$target/.cursor/rules/pegasus-memory.mdc" "context compaction"
assert_file_contains "$target/docs/pegasus/memory/context.md" "Read this file at the start"

if grep -R -E 'Gentle AI|Engram' "$target" >/dev/null; then
  printf 'generated public files contain banned references\n' >&2
  exit 1
fi

printf 'user content\n' > "$target/AGENTS.md"
printf 'custom decisions\n' > "$target/docs/pegasus/memory/decisions.md"
if "$PYTHON_BIN" "$CLI" --project-name sample-project --target-path "$target" >/dev/null 2>&1; then
  printf 'expected conflict failure\n' >&2
  exit 1
fi
assert_file_contains "$target/AGENTS.md" "user content"
assert_file_contains "$target/docs/pegasus/memory/decisions.md" "custom decisions"

force_output="$($PYTHON_BIN "$CLI" --project-name sample-project --target-path "$target" --force)"
case "$force_output" in
  *"Overwrites (--force):"*"$target/AGENTS.md"*) ;;
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
  *"Global Cursor rules (--install-cursor-global):"*"$global_xdg/Cursor/User/rules"*"pegasus-global.mdc"*) ;;
  *) printf 'expected global dry-run output to list intended global operations\n' >&2; exit 1 ;;
esac
[ ! -e "$global_dry_target" ] || { printf 'global dry-run wrote target files\n' >&2; exit 1; }
[ ! -e "$global_xdg/Cursor" ] || { printf 'global dry-run wrote Cursor config\n' >&2; exit 1; }

global_target="$TMP/global-target"
global_output="$(HOME="$global_home" XDG_CONFIG_HOME="$global_xdg" "$PYTHON_BIN" "$CLI" --project-name global-project --target-path "$global_target" --install-cursor-global)"
global_rule="$global_xdg/Cursor/User/rules/pegasus-global.mdc"
[ -f "$global_rule" ] || { printf 'expected global Cursor rule to be written\n' >&2; exit 1; }
assert_file_contains "$global_rule" "PEGASUS-CURSOR-GLOBAL"
assert_file_contains "$global_rule" "Pegasus IA Global Cursor Guidance"
case "$global_output" in
  *"Updated global Cursor rules: $global_xdg/Cursor/User/rules"*) ;;
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
