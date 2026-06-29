# Open Island Feishu — 发版与自动更新

## 架构

```
GitHub tag v*  →  Actions: 构建 Universal .app/.zip
              →  Sparkle EdDSA 签名 zip
              →  更新 appcast-feishu.xml 并 push 到 main
              →  创建 GitHub Release（DMG + ZIP）

已安装应用  →  每小时检查 appcast-feishu.xml
           →  设置 → 关于 → 检查更新
```

Appcast 地址（写入 `Info.plist` 的 `SUFeedURL`）：

https://raw.githubusercontent.com/1070124410/open-island-feishu/main/appcast-feishu.xml

## 首次配置 Sparkle 签名密钥（一次性）

Release workflow 需要仓库 Secret `SPARKLE_EDDSA_KEY`（私钥内容，见 `config/sparkle/README.md`）。

在仓库 **Settings → Secrets and variables → Actions** 添加：

| Name | Value |
|------|--------|
| `SPARKLE_EDDSA_KEY` | `config/sparkle/feishu-ed-private.key` 文件全文 |

本地生成密钥（若尚未生成）：

```bash
swift package resolve
.build/artifacts/sparkle/Sparkle/bin/generate_keys --account open-island-feishu
.build/artifacts/sparkle/Sparkle/bin/generate_keys --account open-island-feishu -x config/sparkle/feishu-ed-private.key
.build/artifacts/sparkle/Sparkle/bin/generate_keys --account open-island-feishu -p > config/sparkle/feishu-public-ed-key.txt
```

**切勿**将私钥提交到 git（已在 `.gitignore` 中忽略）。

## 发新版

1. 编写 `docs/release-notes/vX.Y.Z.md`
2. 提交并 push `main`
3. 打 tag 并推送：

```bash
git tag -a v0.0.3 -m "Open Island Feishu v0.0.3"
git push origin v0.0.3
```

4. Actions **Release Feishu** 会自动：构建 **Universal** 包、签名、更新 appcast、发布 Release

## 芯片支持

CI 与默认 `package-feishu-app.sh` 使用 `OPEN_ISLAND_UNIVERSAL=true`，产物为 **fat binary（arm64 + x86_64）**，Intel 与 M 系列均可运行。

验证：

```bash
lipo -info "output/package/Open Island Feishu.app/Contents/MacOS/OpenIslandApp"
# Architectures in the fat file are: x86_64 arm64
```

## 注意

- 仅 **Open Island Feishu**（`app.openisland.feishu`）走此更新源，不会拉到上游 Open Island
- 未签名的本地 dev 构建无 `SUFeedURL`，关于页会提示从 GitHub 手动下载
