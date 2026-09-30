#!/usr/bin/env bash
# Restore wintools apps' settings from the private app-settings repo. Quit the
# apps first. Run in MSYS2 / Git Bash.
#
#   scripts/restore-settings.sh [computer]   default: this computer's backup
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETTINGS_REPO="${SETTINGS_REPO:-$(dirname "$REPO_ROOT")/app-settings}"
HOST="${1:-$(hostname | tr '[:upper:]' '[:lower:]')}"
SRC="$SETTINGS_REPO/windows/$HOST"

git -C "$SETTINGS_REPO" pull -q --ff-only 2>/dev/null || true
[[ -d "$SRC" ]] || { echo "No backup for $HOST in $SETTINGS_REPO/windows/" >&2; exit 1; }

WIN_HOME="$(cygpath -u "$USERPROFILE")"
WOX_USER="$WIN_HOME/.wox/wox-user"
if [[ -f "$WIN_HOME/.wox/.userdata.location" ]]; then
  WOX_USER="$(cygpath -u "$(tr -d '\r\n' < "$WIN_HOME/.wox/.userdata.location")")"
fi

if tasklist //FI "IMAGENAME eq wox.exe" 2>/dev/null | grep -qi wox.exe; then
  echo "Quit Wox first." >&2
  exit 1
fi

mkdir -p "$WOX_USER"
for item in wox.db settings themes plugins; do
  if [[ -e "$SRC/wox/$item" ]]; then
    rm -rf "${WOX_USER:?}/$item"
    cp -R "$SRC/wox/$item" "$WOX_USER/"
    echo "  restored wox/$item"
  fi
done
echo "Done. Start Wox."
