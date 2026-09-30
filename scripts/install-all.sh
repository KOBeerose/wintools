#!/usr/bin/env bash
# Set up wintools on a Windows machine: fetch submodules, add upstream remotes,
# enable the pre-push check, then build and install every tool from source.
# Run in the MSYS2 MINGW64 shell (Wox's build requires it).
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_SCRIPT="scripts/build-install-local.sh"

TOOLS=(
  wox
)

# "folder=url" pairs, not `declare -A`: stays compatible with older bash.
UPSTREAM_REMOTES=(
  "wox=https://github.com/Wox-launcher/Wox.git"
)

case "$(uname -s)" in
  MINGW64_NT*) ;;
  *) echo "Run this in the MSYS2 MINGW64 shell." >&2; exit 1 ;;
esac

cd "$REPO_ROOT"
echo "Initializing submodules..."
git submodule update --init --recursive

echo "Setting up upstream remotes for fork submodules..."
for entry in "${UPSTREAM_REMOTES[@]}"; do
  folder="${entry%%=*}"
  url="${entry#*=}"
  if git -C "$REPO_ROOT/$folder" remote get-url upstream &>/dev/null; then
    echo "  $folder: upstream already set"
  else
    git -C "$REPO_ROOT/$folder" remote add upstream "$url"
    echo "  $folder: upstream added -> $url"
  fi
done

echo "Enabling the pre-push submodule check..."
chmod +x "$REPO_ROOT/.githooks/"*
git config core.hooksPath .githooks
echo

FAILED=()
for tool in "${TOOLS[@]}"; do
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Installing $tool..."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  if (cd "$REPO_ROOT/$tool" && bash "$BUILD_SCRIPT"); then
    echo "  ✓ $tool installed"
  else
    echo "  ✗ $tool failed"
    FAILED+=("$tool")
  fi
  echo
done

echo "Done: $(( ${#TOOLS[@]} - ${#FAILED[@]} ))/${#TOOLS[@]} tools installed"
if [[ ${#FAILED[@]} -gt 0 ]]; then
  printf '  - %s\n' "${FAILED[@]}"
  exit 1
fi
