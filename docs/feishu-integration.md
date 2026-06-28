# Open Island + 飞书远程审批

本 fork 在 [8676311081/open-island](https://github.com/8676311081/open-island) 基础上集成 [open-island-feishu](https://github.com/1070124410/open-island-feishu) sidecar：

- **Settings → 飞书**：原生配置页（凭据、超时、Hook 注入、测试卡片）
- **菜单栏 → 飞书远程审批**：快捷打开设置 / 暂停推送

## 依赖

1. 安装 sidecar：`~/open-island-feishu/scripts/install.sh`
2. 确保 `feishu-bridged` 在运行（launchd `app.openisland.feishu`）
3. Admin API 默认：`http://127.0.0.1:8742`

## 构建

```bash
cd ~/open-island
swift build
open Package.swift
```

Sidecar 为独立 MIT 项目；Open Island 本体仍为 GPL-3.0。

## 自动更新（Sparkle）

官方 appcast 指向 [Octane0411/open-vibe-island](https://github.com/Octane0411/open-vibe-island)（当前最新 **v1.1.3**）。

**飞书定制版（`*-feishu`）请勿点「更新到 v1.1.3」**——会安装无飞书 Tab 的官方包。

定制版打包时会移除 `SUFeedURL` 并关闭 Sparkle 自动检查。重新安装：

```bash
OPEN_ISLAND_VERSION=1.0.29-feishu zsh ~/open-island/scripts/package-app.sh
cp -R ~/open-island/output/package/Open\ Island.app /Applications/
```
