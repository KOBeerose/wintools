#!/usr/bin/env bash
# Start kanata with wintools' layout (config/kanata.kbd) now and at every login.
# Run in MSYS2 / Git Bash after kanata/scripts/build-install-local.sh.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXE="$(cygpath -w "$(cygpath -u "$LOCALAPPDATA")/Programs/kanata/kanata.exe")"
CFG="$(cygpath -w "$REPO_ROOT/config/kanata.kbd")"

[[ -f "$(cygpath -u "$EXE")" ]] || { echo "kanata isn't installed yet: bash kanata/scripts/build-install-local.sh" >&2; exit 1; }
"$(cygpath -u "$EXE")" --check --cfg "$CFG" >/dev/null || { echo "config/kanata.kbd has errors (see: kanata --check)" >&2; exit 1; }

# Startup-folder shortcut: runs as you at login, no admin, easy to remove.
powershell.exe -NoProfile -Command "
  \$lnk = Join-Path ([Environment]::GetFolderPath('Startup')) 'kanata.lnk'
  \$s = (New-Object -ComObject WScript.Shell).CreateShortcut(\$lnk)
  \$s.TargetPath = '$EXE'
  \$s.Arguments = '--cfg \"$CFG\"'
  \$s.WindowStyle = 7
  \$s.Save()
  Write-Output \"login item: \$lnk\"
"

taskkill //IM kanata.exe //F >/dev/null 2>&1 || true
powershell.exe -NoProfile -Command "Start-Process -FilePath '$EXE' -ArgumentList '--cfg \"$CFG\"' -WindowStyle Minimized"
echo "kanata running with $CFG (tray icon; edit the config, then re-run this script)."
