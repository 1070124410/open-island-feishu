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

**请勿**对本应用使用上游 Open Island 的 Sparkle 更新源——会安装无飞书集成的官方包。

请从 [open-island-feishu Releases](https://github.com/1070124410/open-island-feishu/releases) 获取新版本。打包时会移除 `SUFeedURL` 并关闭 Sparkle 自动检查。
