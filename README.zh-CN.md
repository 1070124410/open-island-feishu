<p align="center">
  <img src="docs/images/readme-banner.svg" alt="Open Island Feishu" width="760">
</p>

<h1 align="center">Open Island Feishu</h1>

<p align="center">
  <strong>在 Open Island 上增加飞书远程审批与岛栏个性化</strong>
  <br>
  基于 <a href="https://github.com/Octane0411/open-vibe-island">Open Island</a> 的定制 fork，可与官方版同时安装。
  <br><br>
  <strong>中文</strong> · <a href="README.md">English</a>
</p>

<p align="center">
  <a href="https://github.com/1070124410/open-island-feishu/releases/latest"><img src="https://img.shields.io/github/v/release/1070124410/open-island-feishu?style=flat-square&label=release&color=blue" alt="Release"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/应用-GPL%20v3-green?style=flat-square" alt="GPL-3.0"></a>
  <a href="https://github.com/1070124410/vibe-island-feishu"><img src="https://img.shields.io/badge/sidecar-MIT-blue?style=flat-square" alt="Sidecar MIT"></a>
</p>

<p align="center">
  <a href="https://github.com/1070124410/open-island-feishu/releases">下载</a> ·
  <a href="#本仓库新增功能">新增功能</a> ·
  <a href="#快速开始">快速开始</a> ·
  <a href="docs/feishu-integration.md">飞书文档</a>
</p>

---

## 这是什么？

**Open Island Feishu** 保留 [Open Island](https://github.com/Octane0411/open-vibe-island) 的全部能力——灵动岛/顶栏悬浮、多 Agent Hook、本地审批 UI、终端跳回——并在此基础上增加 **飞书远程审批** 和一批 **岛栏体验优化**。

适合这样的场景：工位前用原生岛栏审批；**离开电脑时在飞书私聊里点卡片**批准权限、回答问题或确认 Plan，而不必把 AI 会话卡死几小时。

```
Agent Hook ──► Open Island Feishu（本地 UI，约 30 秒）
                    │
                    └──► vibe-island-feishu 守护进程 ──► 飞书卡片推送到手机
                         （本地与飞书竞速，谁先响应谁生效）
```

| 组件 | 仓库 | 协议 |
|------|------|------|
| macOS 应用 | **本仓库** | GPL-3.0 |
| 飞书 sidecar | [vibe-island-feishu](https://github.com/1070124410/vibe-island-feishu) | MIT |

---

## 本仓库新增功能

> 以下均为在 upstream Open Island **v1.1.3** 之上的增量。Agent / 终端兼容列表见 [上游 README](https://github.com/Octane0411/open-vibe-island/blob/main/README.zh-CN.md)。

### 1. 飞书远程审批（核心）

- **设置 → 飞书远程审批**：独立 Tab，与「安装引导」同级，不再藏在折叠区块里
- **5 步新手引导**：安装 sidecar → 填写飞书应用凭据 → 安装 Agent Hook → 接入飞书 Bridge → 发送测试卡片
- **本地 Go sidecar**（[vibe-island-feishu](https://github.com/1070124410/vibe-island-feishu)）：岛栏本地 UI 超时未响应时，将待审批的权限 / 问答 / Plan 以 **飞书交互卡片** 发到你的私聊
- **竞速模型**：本地岛栏 vs 飞书，**先响应的一方生效**，另一方静默结束
- **应用内管控**：开关推送、本地超时、飞书最长等待、各 IDE Hook 接入状态、一键套 Bridge、测试消息
- **凭据辅助**：自动获取 `open_id`；权限不足时展示简短说明 + **可复制/打开的飞书开放平台链接**

### 2. 岛栏与设置交互

- **展开岛栏顶栏简化**：静音 · **设置** · 退出 — 齿轮**直接进入设置**，不再有齿轮子菜单
- **飞书远程审批** 为一级设置项
- **移除会话**：展开列表中可 dismiss 过期条目（不杀 Agent 进程）

### 3. 个性化与外观

- **双屏独立配置**：**MacBook 刘海屏** 与 **外接屏** 各一套偏好；悬浮岛切换屏幕时 **自动套用** 对应 profile
- **应用到岛栏**：编辑非当前屏配置时，可一键强制刷新 live 岛栏
- **左槽「自定义」**（原「宠物」改名）：
  - **Scout** 品牌图标
  - **文本** — emoji 或短文案，可调 **展示宽度（2～12 字）**，支持 **从左向右循环滚动**
  - **自己上传的图片** — 本地 PNG/JPEG/GIF/WebP/SVG
- **用量展示**：从顶栏 chips 挪到展开列表 **Agent 分组标题右侧**（紧凑样式；需在分组中选 **按 Agent**）

### 4. 独立产品标识（可与官方并存）

| | 官方 Open Island | **Open Island Feishu** |
|---|---|---|
| 应用名 | Open Island | **Open Island Feishu** |
| Bundle ID | `app.openisland.dev` | **`app.openisland.feishu`** |
| 数据目录 | `~/Library/Application Support/OpenIsland/` | **`~/Library/Application Support/OpenIslandFeishu/`** |
| 飞书集成 | 无 | **内置** |
| Sparkle 更新 | 上游源 | **已禁用**（上游更新会覆盖飞书功能） |

---

## 快速开始

### 1. 安装应用

从 [Releases](https://github.com/1070124410/open-island-feishu/releases/latest) 下载 **`Open Island Feishu.dmg`**，拖入 `/Applications`。

或源码打包（macOS 14+）：

```bash
git clone https://github.com/1070124410/open-island-feishu.git
cd open-island-feishu
chmod +x scripts/package-feishu-app.sh
# 可选：python3 -m venv .venv && .venv/bin/pip install Pillow
PATH="$PWD/.venv/bin:$PATH" zsh scripts/package-feishu-app.sh
cp -R "output/package/Open Island Feishu.app" /Applications/
```

### 2. 安装飞书 sidecar

1. 到 [Releases](https://github.com/1070124410/open-island-feishu/releases/latest) 下载对应你机器的 tarball：
   - Apple Silicon（M1/M2/M3/M4）→ `open-island-feishu-darwin-arm64.tar.gz`
   - Intel Mac → `open-island-feishu-darwin-amd64.tar.gz`
2. 双击 `.tar.gz` 解压（macOS 自带解压）。
3. 进入解压出来的文件夹，**右键点击 `Install.command` → 打开**（首次必须右键打开一次，否则 macOS Gatekeeper 会拒绝；以后双击就行）。
4. 弹出的 Terminal 窗口跑完后会提示 `✅ 安装完成`，按任意键关闭。

`Install.command` 内部就是 `scripts/install.sh`：剥离 `com.apple.quarantine` → ad-hoc 签名所有二进制 → 装到 `~/.local/bin` → 镜像一份到 `~/open-island-feishu/`（让 Open Island 的"安装本地飞书插件"按钮以后能复用）→ 加载 launchd 守护进程 `app.openisland.feishu`（管理 API 默认 `http://127.0.0.1:8742`）。

> 想用命令行？进入解压目录直接跑 `./scripts/install.sh` 即可。

### 3. 在应用内一次性配置

1. 打开 **Open Island Feishu**
2. **设置 → 飞书远程审批** — 按 5 步引导操作
3. **设置 → 安装引导** — 为在用的 Agent 安装 Hook（Claude Code、Codex 等）
4. 回到飞书 Tab — 对需要的 IDE **接入飞书 Bridge**，再 **发送测试卡片**

更多说明：[docs/feishu-integration.md](./docs/feishu-integration.md) · sidecar：[vibe-island-feishu](https://github.com/1070124410/vibe-island-feishu)

---

## 继承自 Open Island 的能力

本 fork 基于 [open-vibe-island](https://github.com/Octane0411/open-vibe-island) **v1.1.3**，包含：

- 刘海/顶栏收起岛、展开会话列表、权限与问答界面
- Claude Code、Codex、Cursor、Gemini CLI、Kimi、OpenCode、Qoder、Qwen、Factory、CodeBuddy 等 Hook
- 跳回 Terminal.app、Ghostty、iTerm2、VS Code、Cursor、JetBrains 等

完整 Agent / 终端矩阵不在此重复，请查阅上游文档。

---

## 构建与发布

```bash
OPEN_ISLAND_VERSION=0.0.1 zsh scripts/package-feishu-app.sh
```

产物位于 `output/package/`：

- `Open Island Feishu.app`
- `Open Island Feishu.dmg` / `.zip`

> **更新：** 请只从 [本仓库 Releases](https://github.com/1070124410/open-island-feishu/releases) 安装。勿用官方 Open Island 的 Sparkle 更新，否则会装回无飞书 Tab 的上游包。

---

## 开源协议与归属

| 组件 | 协议 |
|------|------|
| Open Island Feishu（本仓库） | [GPL-3.0](./LICENSE)，Open Island 衍生作品 |
| [vibe-island-feishu](https://github.com/1070124410/vibe-island-feishu) sidecar | MIT |

再分发要求见 [NOTICE](./NOTICE)。

**致谢**

- [Open Island / open-vibe-island](https://github.com/Octane0411/open-vibe-island) — 上游（GPL-3.0）
- [vibe-island-feishu](https://github.com/1070124410/vibe-island-feishu) — 飞书桥接守护进程（MIT）
