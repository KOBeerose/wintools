# wintools

Windows tools, built from reviewed source. Companion to [mactools](https://github.com/KOBeerose/mactools): same pattern, same forks where a tool is cross-platform.

## Installation

In the **MSYS2 MINGW64** shell (Wox's build requires it):

```bash
git clone --recurse-submodules https://github.com/KOBeerose/wintools.git
cd wintools
bash scripts/install-all.sh
```

Settings backups go to the private [app-settings](https://github.com/KOBeerose/app-settings) repo. Clone it next to `wintools`, then `bash scripts/backup-settings.sh` / `bash scripts/restore-settings.sh`.

## Tools

| Tool | Purpose | Status | Build / Install | Permissions |
| --- | --- | --- | --- | --- |
| `wox` | Fork of [Wox-launcher/Wox](https://github.com/Wox-launcher/Wox). Launcher: apps, calculator with currency and units, window halves, clipboard, AI. Local changes (see `wox/FORK.md`): no telemetry, no auto-update, no background fetches, plugin hosts bound to localhost, locked Python host build. | Active | `cd wox && bash scripts/build-install-local.sh` | None (unsigned: Smart App Control / AV may ask) |
| `kanata` | Fork of [jtroo/kanata](https://github.com/jtroo/kanata), on release tags. Keyboard layers matching mactools' BetterModifiers: Caps hold = Ctrl, Tab hold = navigation layer (window halves, clipboard, emoji, screenshot, launcher). Layout in `config/kanata.kbd`. Built with `gui` only (no TCP server, no command running, no driver). | Active | `cd kanata && bash scripts/build-install-local.sh`, then `bash scripts/setup-kanata.sh` | None (low-level keyboard hook, no admin) |

## Keeping forks safe

- `scripts/audit-upstream.sh <submodule>` prints what upstream's latest release would bring in (dependencies, permissions, build scripts, updater, network code, agent/CI files) without merging. Sync to release tags.
- `install-all.sh` enables a pre-push hook that refuses to push while a submodule points at a commit its fork doesn't have.
- Each fork's `FORK.md` lists its changes; re-check them after every sync.
- The shared tooling (`audit-upstream.sh`, `.githooks/`, `.cursor/skills/`) is copied from mactools. Keep the two in step when you change either.
