#!/usr/bin/env bash
# Back up wintools apps' settings into the private app-settings repo, under
# windows/<computer>/, then commit and push. Run in MSYS2 / Git Bash.
#
#   SETTINGS_REPO=<path>   clone of KOBeerose/app-settings (default: next to wintools)
#   INCLUDE_HISTORY=1      also back up Wox clipboard history (off: it can hold secrets)
#   NO_PUSH=1              commit only
#
# Wox keeps settings, AI API keys, query history and chats together in wox.db,
# so the backup includes it. app-settings is private, but GitHub can read it:
# rotate an API key if you ever make the repo public.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETTINGS_REPO="${SETTINGS_REPO:-$(dirname "$REPO_ROOT")/app-settings}"
HOST="$(hostname | tr '[:upper:]' '[:lower:]')"
DEST="$SETTINGS_REPO/windows/$HOST"

[[ -d "$SETTINGS_REPO/.git" ]] || {
  echo "No app-settings clone at $SETTINGS_REPO. Clone it first:" >&2
  echo "  git clone https://github.com/KOBeerose/app-settings.git \"$SETTINGS_REPO\"" >&2
  exit 1
}

WIN_HOME="$(cygpath -u "$USERPROFILE")"
WOX_DATA="$WIN_HOME/.wox"
# Wox can relocate its user data; it records the path in .userdata.location.
WOX_USER="$WOX_DATA/wox-user"
if [[ -f "$WOX_DATA/.userdata.location" ]]; then
  WOX_USER="$(cygpath -u "$(tr -d '\r\n' < "$WOX_DATA/.userdata.location")")"
fi

if tasklist //FI "IMAGENAME eq wox.exe" 2>/dev/null | grep -qi wox.exe; then
  echo "Quit Wox first (its database can change mid-copy)." >&2
  exit 1
fi

rm -rf "$DEST/wox"
mkdir -p "$DEST/wox"
for item in wox.db settings themes plugins; do
  [[ -e "$WOX_USER/$item" ]] && cp -R "$WOX_USER/$item" "$DEST/wox/" && echo "  saved wox/$item"
done
if [[ "${INCLUDE_HISTORY:-0}" != 1 ]]; then
  find "$DEST/wox/settings" -name '*_clipboard.db*' -delete 2>/dev/null || true
fi

cd "$SETTINGS_REPO"
git add -A "windows/$HOST"
if git diff --cached --quiet; then
  echo "No changes since the last backup."
  exit 0
fi
git commit -q -m "backup windows/$HOST"
[[ "${NO_PUSH:-0}" == 1 ]] || git push -q
echo "Backed up to app-settings/windows/$HOST$([[ "${NO_PUSH:-0}" == 1 ]] && echo " (not pushed)")."
