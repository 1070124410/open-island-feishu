<p align="center">
  <img src="docs/images/readme-banner.svg" alt="Open Island Feishu" width="760">
</p>

<h1 align="center">Open Island Feishu</h1>

<p align="center">
  <strong>Feishu remote approval + island personalization on top of Open Island</strong>
  <br>
  Fork of <a href="https://github.com/Octane0411/open-vibe-island">Open Island</a> — installs alongside the official app.
  <br><br>
  <a href="README.zh-CN.md">中文</a> · <strong>English</strong>
</p>

<p align="center">
  <a href="https://github.com/1070124410/open-island-feishu/releases/latest"><img src="https://img.shields.io/github/v/release/1070124410/open-island-feishu?style=flat-square&label=release&color=blue" alt="Release"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/app-GPL%20v3-green?style=flat-square" alt="GPL-3.0"></a>
  <a href="https://github.com/1070124410/vibe-island-feishu"><img src="https://img.shields.io/badge/sidecar-MIT-blue?style=flat-square" alt="Sidecar MIT"></a>
</p>

<p align="center">
  <a href="https://github.com/1070124410/open-island-feishu/releases">Download</a> ·
  <a href="#whats-added-in-this-fork">What's added</a> ·
  <a href="#quick-start">Quick start</a> ·
  <a href="docs/feishu-integration.md">Feishu docs</a>
</p>

---

## What is this?

**Open Island Feishu** keeps everything [Open Island](https://github.com/Octane0411/open-vibe-island) already does — Dynamic Island / top-bar overlay, multi-agent hooks, permission UI, terminal jump-back — and adds **Feishu (Lark) remote approval** plus several **island UX improvements** we needed for daily use.

Use it when you want to **approve Claude Code / Codex / Cursor / … from your phone** while away from your Mac, without giving up a native local-first island UI at your desk.

```
Agent hook ──► Open Island Feishu (local UI, ~30s)
                    │
                    └──► vibe-island-feishu sidecar ──► Feishu card on your phone
                         (whoever responds first wins)
```

| Piece | Repo | License |
|-------|------|---------|
| macOS app | **this repo** | GPL-3.0 |
| Feishu sidecar | [vibe-island-feishu](https://github.com/1070124410/vibe-island-feishu) | MIT |

---

## What's added in this fork

> Everything below is **on top of** upstream Open Island v1.1.3. For base agent/terminal support, see the [upstream README](https://github.com/Octane0411/open-vibe-island/blob/main/README.md).

### 1. Feishu remote approval (core)

- **Settings → Feishu remote approval** — dedicated tab, not buried inside setup
- **5-step guided onboarding**: install sidecar → app credentials → agent hooks → bridge injection → test card
- **Local Go sidecar** ([vibe-island-feishu](https://github.com/1070124410/vibe-island-feishu)): when the island UI does not respond in time, pending permissions / questions / plans are sent as **Feishu interactive cards**
- **Race model**: local island vs Feishu — first answer wins; the other path is cancelled quietly
- **In-app controls**: enable/disable push, local timeout, max Feishu wait, per-IDE hook bridge status, one-click inject, test message
- **Credential helpers**: `open_id` probe with copyable Feishu Open Platform permission links when scopes are missing

### 2. Island bar & settings UX

- **Simpler expanded header**: mute · **settings** · quit — single gear opens Settings (no nested gear submenu)
- **Feishu tab** at the same level as Appearance / Setup
- **Remove session** from the expanded session list (dismiss stale entries without killing the agent)

### 3. Appearance & personalization

- **Dual display profiles** — separate prefs for **MacBook notch** vs **external display**; the overlay **auto-applies** the matching profile when it moves between screens
- **Apply to island** — force-refresh the live island when editing a profile that is not on the active screen
- **Left slot → Custom** (renamed from “pet”):
  - **Scout** brand mark
  - **Text** — emoji or short label, configurable visible width (2–12 chars), optional **left-to-right scroll** loop
  - **Uploaded image** — local PNG/JPEG/GIF/WebP/SVG
- **Usage chips** moved from the top bar to the **Agent group header** in the expanded list (compact style; requires **group by Agent**)

### 4. Standalone product identity

So you can keep official **Open Island** installed for comparison or daily driver:

| | Official Open Island | **Open Island Feishu** |
|---|---|---|
| App name | Open Island | **Open Island Feishu** |
| Bundle ID | `app.openisland.dev` | **`app.openisland.feishu`** |
| App Support | `~/Library/Application Support/OpenIsland/` | **`~/Library/Application Support/OpenIslandFeishu/`** |
| Feishu integration | — | **built-in** |
| Sparkle updates | upstream appcast | **this repo's appcast** (not upstream) |

---

## Quick start

### 1. Install the app

Download **`Open Island Feishu.dmg`** from [Releases](https://github.com/1070124410/open-island-feishu/releases/latest) → drag to `/Applications`.

Or build (macOS 14+):

```bash
git clone https://github.com/1070124410/open-island-feishu.git
cd open-island-feishu
chmod +x scripts/package-feishu-app.sh
# optional: python3 -m venv .venv && .venv/bin/pip install Pillow
PATH="$PWD/.venv/bin:$PATH" zsh scripts/package-feishu-app.sh
cp -R "output/package/Open Island Feishu.app" /Applications/
```

### 2. Install the Feishu sidecar

```bash
git clone https://github.com/1070124410/vibe-island-feishu.git ~/open-island-feishu
cd ~/open-island-feishu && ./scripts/install.sh
```

Sidecar runs as launchd job `app.openisland.feishu`, admin API `http://127.0.0.1:8742`.

### 3. Configure once in the app

1. Open **Open Island Feishu**
2. **Settings → Feishu remote approval** — follow the 5 steps
3. **Settings → Setup** — install hooks for your agents (Claude Code, Codex, …)
4. Back on Feishu tab — **inject Feishu bridge** on the IDEs you use, then **send test card**

More detail: [docs/feishu-integration.md](./docs/feishu-integration.md) · sidecar README: [vibe-island-feishu](https://github.com/1070124410/vibe-island-feishu)

---

## Inherited from Open Island

This fork is based on [open-vibe-island](https://github.com/Octane0411/open-vibe-island) **v1.1.3**, including:

- Notch / top-bar closed island, expanded session list, permission & question surfaces
- Hooks for Claude Code, Codex, Cursor, Gemini CLI, Kimi, OpenCode, Qoder, Qwen, Factory, CodeBuddy
- Jump-back to Terminal.app, Ghostty, iTerm2, VS Code, Cursor, JetBrains, …

We do **not** duplicate that full matrix here — see upstream docs for agent/terminal compatibility.

---

## Build & release

```bash
OPEN_ISLAND_VERSION=0.0.3 OPEN_ISLAND_UNIVERSAL=true zsh scripts/package-feishu-app.sh
```

Artifacts under `output/package/`:

- `Open Island Feishu.app` — **Universal** (Intel + Apple Silicon)
- `Open Island Feishu.dmg` / `.zip`

**In-app updates (v0.0.3+):** Settings → About → Check for Updates. Sparkle pulls [appcast-feishu.xml](https://raw.githubusercontent.com/1070124410/open-island-feishu/main/appcast-feishu.xml) after each [GitHub Release](https://github.com/1070124410/open-island-feishu/releases). Maintainer flow: [docs/feishu-releasing.md](./docs/feishu-releasing.md).

> Do **not** use upstream Open Island's Sparkle feed — it installs a build without the Feishu tab.

---

## License & attribution

| Component | License |
|-----------|---------|
| Open Island Feishu (this repo) | [GPL-3.0](./LICENSE) — derivative of Open Island |
| [vibe-island-feishu](https://github.com/1070124410/vibe-island-feishu) sidecar | MIT |

See [NOTICE](./NOTICE) for redistribution requirements.

**Credits**

- [Open Island / open-vibe-island](https://github.com/Octane0411/open-vibe-island) — upstream (GPL-3.0)
- [vibe-island-feishu](https://github.com/1070124410/vibe-island-feishu) — Feishu bridge daemon (MIT)
