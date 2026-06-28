<p align="center">
  <img src="docs/images/readme-banner.svg" alt="Open Island Feishu — agents in your notch + Feishu remote approval" width="760">
</p>

<h1 align="center">Open Island Feishu</h1>

<p align="center">
  <strong>开源 macOS 灵动岛 Agent 监控 + 飞书远程审批</strong>
  <br>
  基于 <a href="https://github.com/Octane0411/open-vibe-island">Open Island</a>，可与官方 Open Island 同时安装。
  <br><br>
  <a href="README.zh-CN.md">中文</a> | <strong>English</strong>
</p>

<p align="center">
  <a href="https://github.com/1070124410/open-island-feishu/releases/latest"><img src="https://img.shields.io/github/v/release/1070124410/open-island-feishu?style=flat-square&label=release&color=blue" alt="Latest Release"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-GPL%20v3-green?style=flat-square" alt="License: GPL v3"></a>
  <a href="https://github.com/1070124410/vibe-island-feishu"><img src="https://img.shields.io/badge/sidecar-MIT-blue?style=flat-square" alt="Sidecar: MIT"></a>
</p>

<p align="center">
  <a href="https://github.com/1070124410/open-island-feishu/releases">Download</a> ·
  <a href="#quick-start">Quick Start</a> ·
  <a href="docs/feishu-integration.md">Feishu Integration</a> ·
  <a href="NOTICE">NOTICE</a>
</p>

---

## What is Open Island Feishu?

**Open Island Feishu** is a macOS menu-bar / Dynamic Island companion for AI coding agents (Claude Code, Codex, Cursor, Gemini CLI, …), extended with **Feishu (Lark) remote approval** when you are away from your desk.

| Component | Role |
|-----------|------|
| **Open Island Feishu.app** | Native SwiftUI UI, hooks installer, island overlay |
| **[vibe-island-feishu](https://github.com/1070124410/vibe-island-feishu)** sidecar | Local Go daemon — forwards pending approvals to Feishu cards |

### vs official Open Island

| | [Open Island](https://github.com/Octane0411/open-vibe-island) | **Open Island Feishu** (this repo) |
|---|---|---|
| App name | Open Island | **Open Island Feishu** |
| Bundle ID | `app.openisland.dev` | **`app.openisland.feishu`** |
| Data dir | `~/Library/Application Support/OpenIsland/` | **`~/Library/Application Support/OpenIslandFeishu/`** |
| Feishu remote approval | — | Built-in settings tab |
| Can install together | Yes | Yes |

> Do **not** use upstream Sparkle updates on this build — they replace the Feishu integration. Use [releases from this repo](https://github.com/1070124410/open-island-feishu/releases) instead.

---

## Quick Start

### 1. Install the app

Download **`Open Island Feishu.dmg`** from [Releases](https://github.com/1070124410/open-island-feishu/releases/latest) and drag **Open Island Feishu** to `/Applications`.

Or build from source (macOS 14+):

```bash
git clone https://github.com/1070124410/open-island-feishu.git
cd open-island-feishu
chmod +x scripts/package-feishu-app.sh
PATH="$PWD/.venv/bin:$PATH" zsh scripts/package-feishu-app.sh   # needs Python + Pillow for icons
cp -R "output/package/Open Island Feishu.app" /Applications/
```

### 2. Install the Feishu sidecar

```bash
git clone https://github.com/1070124410/vibe-island-feishu.git ~/open-island-feishu
cd ~/open-island-feishu && ./scripts/install.sh
```

### 3. Configure in the app

1. Launch **Open Island Feishu**
2. Open **Settings → 飞书远程审批**
3. Follow the setup guide: credentials, hook injection, test card

See [docs/feishu-integration.md](./docs/feishu-integration.md) for details.

---

## Build

```bash
swift build                                    # dev build
OPEN_ISLAND_VERSION=0.0.1 zsh scripts/package-feishu-app.sh
```

Outputs:

- `output/package/Open Island Feishu.app`
- `output/package/Open Island Feishu.dmg`
- `output/package/Open Island Feishu.zip`

---

## License

- **This app (open-island-feishu):** [GPL-3.0](./LICENSE) — derived from [Open Island](https://github.com/Octane0411/open-vibe-island)
- **Feishu sidecar ([vibe-island-feishu](https://github.com/1070124410/vibe-island-feishu)):** MIT

See [NOTICE](./NOTICE) for attribution requirements.

---

## Credits

- [Open Island / open-vibe-island](https://github.com/Octane0411/open-vibe-island) — upstream macOS agent companion (GPL-3.0)
- [vibe-island-feishu](https://github.com/1070124410/vibe-island-feishu) — Feishu remote approval sidecar (MIT)
