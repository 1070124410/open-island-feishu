# Open Island + 飞书远程审批

本仓库 **Open Island Feishu** 在 [Open Island / open-vibe-island](https://github.com/Octane0411/open-vibe-island) 基础上集成 [vibe-island-feishu](https://github.com/1070124410/vibe-island-feishu) sidecar：

- **设置 → 飞书远程审批**：凭据、超时、Hook 注入、测试卡片、新手引导
- **岛栏 → 齿轮 / 飞书入口**：快捷打开设置或飞书 Tab
- **与官方 Open Island 并存**：独立 Bundle ID `app.openisland.feishu`，数据目录 `~/Library/Application Support/OpenIslandFeishu/`

## 依赖

1. 安装 sidecar：`git clone https://github.com/1070124410/vibe-island-feishu.git ~/open-island-feishu && cd ~/open-island-feishu && ./scripts/install.sh`
2. 确保 `feishu-bridged` 在运行（launchd `app.openisland.feishu`）
3. Admin API 默认：`http://127.0.0.1:8742`

## 构建与安装

```bash
cd open-island-feishu
chmod +x scripts/package-feishu-app.sh
OPEN_ISLAND_VERSION=0.0.1 zsh scripts/package-feishu-app.sh
cp -R "output/package/Open Island Feishu.app" /Applications/
```

Sidecar 为独立 MIT 项目；Open Island Feishu 本体为 GPL-3.0。见 [NOTICE](../NOTICE)。

## 自动更新

从 **v0.0.3** 起，正式 Release 内置 Sparkle，更新源为本仓库的 `appcast-feishu.xml`（**不是**上游 Open Island）。

- 应用内：**设置 → 关于 → 检查更新**
- 手动下载：[Releases](https://github.com/1070124410/open-island-feishu/releases)
- 发版说明：[docs/feishu-releasing.md](./feishu-releasing.md)

**请勿**使用上游 Open Island 的 Sparkle 更新——会覆盖为无飞书集成的官方包。

Release 包为 **Universal 二进制**（Intel + Apple Silicon）。v0.0.2 及更早版本需手动安装一次 v0.0.3+ 后才能使用应用内更新。
