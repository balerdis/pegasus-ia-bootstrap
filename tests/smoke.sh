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

default_plan="$($PYTHON_BIN "$CLI" --project-name default-project --dry-run)"
case "$default_plan" in
  *"Target: /var/www/html/personal/default-project"*) ;;
  *) printf 'expected default target path in dry-run output\n' >&2; exit 1 ;;
esac

dry_target="$TMP/dry-run-project"
"$PYTHON_BIN" "$CLI" --project-name dry-run-project --target-path "$dry_target" --dry-run >/dev/null
[ ! -e "$dry_target" ] || { printf 'dry-run wrote files\n' >&2; exit 1; }

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

if "$PYTHON_BIN" "$CLI" --project-name '../bad' --target-path "$TMP/bad" >/dev/null 2>&1; then
  printf 'expected invalid project-name failure\n' >&2
  exit 1
fi

printf 'Smoke tests passed.\n'
