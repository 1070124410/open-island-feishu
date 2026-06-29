#!/bin/zsh
# Package **Open Island Feishu** — coexists with upstream Open Island in /Applications.
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"

export OPEN_ISLAND_APP_NAME="${OPEN_ISLAND_APP_NAME:-Open Island Feishu}"
export OPEN_ISLAND_BUNDLE_ID="${OPEN_ISLAND_BUNDLE_ID:-app.openisland.feishu}"
export OPEN_ISLAND_VERSION="${OPEN_ISLAND_VERSION:-0.0.1}"
export OPEN_ISLAND_UNIVERSAL="${OPEN_ISLAND_UNIVERSAL:-true}"
export OPEN_ISLAND_APPCAST_URL="${OPEN_ISLAND_APPCAST_URL:-https://raw.githubusercontent.com/1070124410/open-island-feishu/main/appcast-feishu.xml}"
export OPEN_ISLAND_ZIP_PATH="${OPEN_ISLAND_ZIP_PATH:-$repo_root/output/package/Open.Island.Feishu.zip}"
export OPEN_ISLAND_DMG_PATH="${OPEN_ISLAND_DMG_PATH:-$repo_root/output/package/Open Island Feishu.dmg}"

if [[ -z "${OPEN_ISLAND_EDDSA_PUBLIC_KEY:-}" && -f "$repo_root/config/sparkle/feishu-public-ed-key.txt" ]]; then
    export OPEN_ISLAND_EDDSA_PUBLIC_KEY="$(tr -d '[:space:]' < "$repo_root/config/sparkle/feishu-public-ed-key.txt")"
fi

exec zsh "$repo_root/scripts/package-app.sh" "$@"
