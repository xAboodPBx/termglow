#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export TERMGlow_ROOT="$ROOT"
# shellcheck disable=SC1091
source "$ROOT/lib/termglow.sh"

TMP_CONFIG="$(mktemp -d)"
trap 'rm -rf "$TMP_CONFIG"' EXIT
TERMGlow_CONFIG_DIR="$TMP_CONFIG/config"
TERMGlow_THEME_FILE="$TERMGlow_CONFIG_DIR/theme"

assert_contains() {
  local haystack="$1"
  local needle="$2"
  if ! grep -Fq -- "$needle" <<< "$haystack"; then
    printf 'Assertion failed: expected output to contain "%s"\n' "$needle" >&2
    exit 1
  fi
}

bash -n "$ROOT/bin/termglow"
bash -n "$ROOT/lib/termglow.sh"
bash -n "$ROOT/install.sh"
bash -n "$ROOT/uninstall.sh"

list_output="$(TERMGlow_CONFIG_DIR="$TERMGlow_CONFIG_DIR" "$ROOT/bin/termglow" list)"
assert_contains "$list_output" "aurora"
assert_contains "$list_output" "neon"
assert_contains "$list_output" "ocean"
assert_contains "$list_output" "monochrome"

help_output="$("$ROOT/bin/termglow" help)"
assert_contains "$help_output" "apply <theme>"

preview_output="$(TERMGlow_CONFIG_DIR="$TERMGlow_CONFIG_DIR" "$ROOT/bin/termglow" preview ocean)"
assert_contains "$preview_output" "Theme: ocean"

TERMGlow_CONFIG_DIR="$TERMGlow_CONFIG_DIR" "$ROOT/bin/termglow" apply neon >/dev/null
[ "$(cat "$TERMGlow_THEME_FILE")" = "neon" ]
[ "$(TERMGlow_CONFIG_DIR="$TERMGlow_CONFIG_DIR" "$ROOT/bin/termglow" current)" = "neon" ]

if TERMGlow_CONFIG_DIR="$TERMGlow_CONFIG_DIR" "$ROOT/bin/termglow" apply does-not-exist >/dev/null 2>&1; then
  printf 'Assertion failed: invalid theme should fail\n' >&2
  exit 1
fi

printf 'All TermGlow tests passed.\n'
