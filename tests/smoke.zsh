#!/bin/zsh

set -euo pipefail

ROOT="${0:A:h:h}"
CLI="$ROOT/bin/fontvault"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/fontvault-smoke.XXXXXX")"

cleanup() {
  rm -rf "$TEST_ROOT"
}
trap cleanup EXIT INT TERM HUP

zsh -n "$CLI"
[[ "$($CLI version)" == "fontvault 1.0.0" ]]
$CLI help | grep -q 'fontvault backup'

mkdir -p "$TEST_ROOT/repo"
git -C "$TEST_ROOT/repo" init -q
XDG_CONFIG_HOME="$TEST_ROOT/config" "$CLI" init --repo "$TEST_ROOT/repo" >/dev/null
grep -q '^REPO_PATH=' "$TEST_ROOT/config/fontvault/config"
XDG_CONFIG_HOME="$TEST_ROOT/config" "$CLI" status >/dev/null

mkdir -p "$TEST_ROOT/font-source" "$TEST_ROOT/font-destination"
printf 'new font data' > "$TEST_ROOT/font-source/Conflict.ttf"
printf 'installed font data' > "$TEST_ROOT/font-destination/Conflict.ttf"
FONTVAULT_SOURCE_ONLY=1 source "$CLI"
restore_font_tree "$TEST_ROOT/font-source" "$TEST_ROOT/font-destination" false skip >/dev/null
[[ "$(<"$TEST_ROOT/font-destination/Conflict.ttf")" == 'installed font data' ]]
restore_font_tree "$TEST_ROOT/font-source" "$TEST_ROOT/font-destination" false overwrite >/dev/null
[[ "$(<"$TEST_ROOT/font-destination/Conflict.ttf")" == 'new font data' ]]

print 'Smoke tests passed. / 基本測試通過。'

