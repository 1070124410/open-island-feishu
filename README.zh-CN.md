<p align="center">
  <img src="docs/images/readme-banner.svg" alt="Open Island Feishu — 灵动岛 Agent 监控 + 飞书远程审批" width="760">
</p>

<h1 align="center">Open Island Feishu</h1>

<p align="center">
  <strong>开源 macOS 灵动岛 Agent 监控 + 飞书远程审批</strong>
  <br>
  基于 <a href="https://github.com/Octane0411/open-vibe-island">Open Island</a>，可与官方 Open Island 同时安装。
  <br><br>
  <strong>中文</strong> | <a href="README.md">English</a>
</p>

<p align="center">
  <a href="https://github.com/1070124410/open-island-feishu/releases/latest"><img src="https://img.shields.io/github/v/release/1070124410/open-island-feishu?style=flat-square&label=release&color=blue" alt="Latest Release"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-GPL%20v3-green?style=flat-square" alt="License: GPL v3"></a>
  <a href="https://github.com/1070124410/vibe-island-feishu"><img src="https://img.shields.io/badge/sidecar-MIT-blue?style=flat-square" alt="Sidecar: MIT"></a>
</p>

<p align="center">
  <a href="https://github.com/1070124410/open-island-feishu/releases">下载</a> ·
  <a href="#快速开始">快速开始</a> ·
  <a href="docs/feishu-integration.md">飞书集成</a> ·
  <a href="NOTICE">NOTICE</a>
</p>

---

## 是什么？

**Open Island Feishu** 是在 [Open Island](https://github.com/Octane0411/open-vibe-island) 基础上增加 **飞书远程审批** 的 macOS 原生应用：在刘海/顶栏展示 Claude Code、Codex、Cursor 等 Agent 状态；离开工位时，审批请求可转发到飞书卡片。

| 组件 | 作用 |
|------|------|
| **Open Island Feishu.app** | 灵动岛 UI、Hook 安装、本地 Bridge |
| **[vibe-island-feishu](https://github.com/1070124410/vibe-island-feishu)** sidecar | Go 守护进程，把待审批请求发到飞书 |

### 与官方 Open Island 的区别

| | [Open Island](https://github.com/Octane0411/open-vibe-island) | **Open Island Feishu**（本仓库） |
|---|---|---|
| 应用名称 | Open Island | **Open Island Feishu** |
| Bundle ID | `app.openisland.dev` | **`app.openisland.feishu`** |
| 数据目录 | `~/Library/Application Support/OpenIsland/` | **`~/Library/Application Support/OpenIslandFeishu/`** |
| 飞书远程审批 | 无 | 内置设置 Tab |
| 能否与官方并存 | 可以 | 可以 |

> 请勿对本定制版使用上游 Sparkle 自动更新，否则会覆盖飞书集成。请使用 [本仓库 Releases](https://github.com/1070124410/open-island-feishu/releases)。

---

## 快速开始

### 1. 安装应用

从 [Releases](https://github.com/1070124410/open-island-feishu/releases/latest) 下载 **`Open Island Feishu.dmg`**，拖入 `/Applications`。

或源码打包（macOS 14+）：

```bash
git clone https://github.com/1070124410/open-island-feishu.git
cd open-island-feishu
chmod +x scripts/package-feishu-app.sh
PATH="$PWD/.venv/bin:$PATH" zsh scripts/package-feishu-app.sh
cp -R "output/package/Open Island Feishu.app" /Applications/
```

### 2. 安装飞书 sidecar

```bash
git clone https://github.com/1070124410/vibe-island-feishu.git ~/open-island-feishu
cd ~/open-island-feishu && ./scripts/install.sh
```

### 3. 在应用内配置

1. 打开 **Open Island Feishu**
2. **设置 → 飞书远程审批**
3. 按引导完成：凭据、Hook 接入、测试卡片

详见 [docs/feishu-integration.md](./docs/feishu-integration.md)。

---

## 构建

```bash
swift build
OPEN_ISLAND_VERSION=0.0.1 zsh scripts/package-feishu-app.sh
```

产物：

- `output/package/Open Island Feishu.app`
- `output/package/Open Island Feishu.dmg`
- `output/package/Open Island Feishu.zip`

---

## 开源协议

- **本应用（open-island-feishu）：** [GPL-3.0](./LICENSE)，基于 [Open Island](https://github.com/Octane0411/open-vibe-island)
- **飞书 sidecar（[vibe-island-feishu](https://github.com/1070124410/vibe-island-feishu)）：** MIT

归属与再分发说明见 [NOTICE](./NOTICE)。

---

## 致谢

- [Open Island / open-vibe-island](https://github.com/Octane0411/open-vibe-island) — 上游 macOS Agent 伴侣（GPL-3.0）
- [vibe-island-feishu](https://github.com/1070124410/vibe-island-feishu) — 飞书远程审批 sidecar（MIT）
