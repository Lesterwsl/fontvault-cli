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
[[ "$($CLI version)" == "fontvault 1.1.0" ]]
$CLI help | grep -q 'fontvault backup'

mkdir -p "$TEST_ROOT/repo"
git -C "$TEST_ROOT/repo" init -q
XDG_CONFIG_HOME="$TEST_ROOT/config" "$CLI" init --repo "$TEST_ROOT/repo" >/dev/null
grep -q '^REPO_PATH=' "$TEST_ROOT/config/fontvault/config"
XDG_CONFIG_HOME="$TEST_ROOT/config" "$CLI" status >/dev/null

FONTVAULT_SOURCE_ONLY=1 source "$CLI"
mkdir "$TEST_ROOT/repo/.fontvault.lock"
stale_stage="$(mktemp -d "${TMPDIR:-/tmp}/fontvault.999999.XXXXXX")"
printf '999999\n' > "$TEST_ROOT/repo/.fontvault.lock/pid"
printf 'old\n' > "$TEST_ROOT/repo/.fontvault.lock/started_at"
printf 'fontvault backup\n' > "$TEST_ROOT/repo/.fontvault.lock/command"
printf '%s\n' "$stale_stage" > "$TEST_ROOT/repo/.fontvault.lock/stage_dir"
acquire_backup_lock "$TEST_ROOT/repo/.fontvault.lock" >/dev/null
[[ ! -e "$stale_stage" ]]
[[ "$(<"$TEST_ROOT/repo/.fontvault.lock/pid")" == "$$" ]]
backup_lock_is_active "$TEST_ROOT/repo/.fontvault.lock"
release_backup_lock "$TEST_ROOT/repo/.fontvault.lock"
[[ ! -e "$TEST_ROOT/repo/.fontvault.lock" ]]

mkdir -p \
  "$TEST_ROOT/previous/homebrew" "$TEST_ROOT/previous/applications" \
  "$TEST_ROOT/previous/fonts/user" "$TEST_ROOT/previous/manifests" \
  "$TEST_ROOT/proposed/homebrew" "$TEST_ROOT/proposed/applications" \
  "$TEST_ROOT/proposed/fonts/user" "$TEST_ROOT/proposed/manifests"
printf 'category\tpath\tbytes\tsha256\npersonal\tuser/Changed.ttf\t10\told-hash\n' > "$TEST_ROOT/previous/manifests/fonts.tsv"
printf 'category\tpath\tbytes\tsha256\npersonal\tuser/Changed.ttf\t11\tnew-hash\npersonal\tuser/Added.otf\t12\tadded-hash\n' > "$TEST_ROOT/proposed/manifests/fonts.tsv"
printf '## Formulae (1) / Formula (1)\n\n| Name / 名稱 | Version / 版本 |\n|---|---|\n| git | 1 |\n' > "$TEST_ROOT/previous/homebrew/homebrew.md"
printf '## Formulae (2) / Formula (2)\n\n| Name / 名稱 | Version / 版本 |\n|---|---|\n| git | 2 |\n| gh | 1 |\n' > "$TEST_ROOT/proposed/homebrew/homebrew.md"
printf '| Application / 應用程式 | Version / 版本 | Source / 來源 |\n|---|---|---|\n| Example | 1 | Other |\n' > "$TEST_ROOT/previous/applications/applications.md"
printf '| Application / 應用程式 | Version / 版本 | Source / 來源 |\n|---|---|---|\n| Example | 2 | Other |\n| New App | 1 | Homebrew |\n' > "$TEST_ROOT/proposed/applications/applications.md"
printf 'old font' > "$TEST_ROOT/previous/fonts/user/Changed.ttf"
printf 'new font' > "$TEST_ROOT/proposed/fonts/user/Changed.ttf"
printf 'added font' > "$TEST_ROOT/proposed/fonts/user/Added.otf"
print_change_summary "$TEST_ROOT/previous" "$TEST_ROOT/proposed" > "$TEST_ROOT/change-output.txt"
change_output="$(<"$TEST_ROOT/change-output.txt")"
grep -q 'Personal fonts / 個人字型: +1 / -0 / ~1' <<< "$change_output"
grep -q 'Homebrew packages / Homebrew 套件: +1 / -0 / ~1' <<< "$change_output"
grep -q 'Applications / 應用程式: +1 / -0 / ~1' <<< "$change_output"
grep -q '+ user/Added.otf' <<< "$change_output"
grep -q 'formula: git (1 → 2)' <<< "$change_output"
grep -q 'Example (1 | Other → 2 | Other)' <<< "$change_output"
(( BACKUP_CHANGE_COUNT > 0 ))

mkdir -p "$TEST_ROOT/shared-previous/fonts/shared" "$TEST_ROOT/shared-previous/manifests" "$TEST_ROOT/shared-proposed"
printf 'shared font' > "$TEST_ROOT/shared-previous/fonts/shared/Shared.ttf"
printf 'category\tpath\tbytes\tsha256\npersonal\tshared/Shared.ttf\t11\tshared-hash\n' > "$TEST_ROOT/shared-previous/manifests/fonts.tsv"
: > "$TEST_ROOT/shared-classification.tsv"
preserve_previous_shared_snapshot \
  "$TEST_ROOT/shared-previous" "$TEST_ROOT/shared-proposed" "$TEST_ROOT/shared-classification.tsv" >/dev/null
cmp "$TEST_ROOT/shared-previous/fonts/shared/Shared.ttf" "$TEST_ROOT/shared-proposed/fonts/shared/Shared.ttf"
grep -q $'^personal\tshared/Shared.ttf\t11\tshared-hash$' "$TEST_ROOT/shared-classification.tsv"

mkdir -p "$TEST_ROOT/font-source" "$TEST_ROOT/font-destination"
printf 'new font data' > "$TEST_ROOT/font-source/Conflict.ttf"
printf 'installed font data' > "$TEST_ROOT/font-destination/Conflict.ttf"
restore_font_tree "$TEST_ROOT/font-source" "$TEST_ROOT/font-destination" false skip >/dev/null
[[ "$(<"$TEST_ROOT/font-destination/Conflict.ttf")" == 'installed font data' ]]
restore_font_tree "$TEST_ROOT/font-source" "$TEST_ROOT/font-destination" false overwrite >/dev/null
[[ "$(<"$TEST_ROOT/font-destination/Conflict.ttf")" == 'new font data' ]]

print 'Smoke tests passed. / 基本測試通過。'

