#!/bin/zsh
# Package **Open Island Feishu** — coexists with upstream Open Island in /Applications.
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"

export OPEN_ISLAND_APP_NAME="${OPEN_ISLAND_APP_NAME:-Open Island Feishu}"
export OPEN_ISLAND_BUNDLE_ID="${OPEN_ISLAND_BUNDLE_ID:-app.openisland.feishu}"
export OPEN_ISLAND_VERSION="${OPEN_ISLAND_VERSION:-0.0.1}"

exec zsh "$repo_root/scripts/package-app.sh" "$@"
