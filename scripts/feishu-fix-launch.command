#!/usr/bin/env bash
# Fix-Launch.command — Repair quarantined Open Island Feishu.app and launch it.
#
# 为什么需要这个脚本：
# Open Island Feishu 目前只做 ad-hoc 代码签名、没有 Apple Developer ID + 公证。
# 从飞书 / 微信 / QQ 等 sandbox IM 应用下载的 dmg/zip 会被 macOS 打上
# com.apple.quarantine 隔离属性，叠加 ad-hoc 签名后被 Gatekeeper 直接拒绝执行
# （崩溃报告体现为启动 25ms 内被 kill、codeSigningTrustLevel=UINT32_MAX）。
# 本脚本做三件事：剥隔离属性 → 重做 ad-hoc 签名 → 启动应用。
#
# Why this script exists:
# Open Island Feishu currently ships ad-hoc signed only (no Apple Developer ID,
# no notarization). When the dmg/zip is downloaded through a sandboxed IM app
# such as Feishu/WeChat/QQ, macOS attaches the com.apple.quarantine attribute,
# and Gatekeeper refuses to execute it (the app is killed in <25 ms at launch
# with codeSigningTrustLevel=UINT32_MAX). This script strips quarantine,
# re-signs ad-hoc, then opens the app.

set -u

APP_NAME="Open Island Feishu.app"
DST_APP="/Applications/$APP_NAME"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_APP=""

if [ -d "$HERE/$APP_NAME" ]; then
  SRC_APP="$HERE/$APP_NAME"
fi

clear
cat <<'BANNER'
==========================================================
  Open Island Feishu  ·  首次启动修复 / First-Launch Fix
==========================================================
BANNER
echo
echo "目标 / Target: $DST_APP"
echo

# 1. 如果 /Applications 还没装，从同目录拷贝过去
if [ ! -d "$DST_APP" ]; then
  if [ -z "$SRC_APP" ]; then
    echo "❌ 没找到 \"$APP_NAME\"。"
    echo "   请先把 \"$APP_NAME\" 拖进 /Applications/，再来双击本脚本。"
    echo
    echo "❌ Could not find \"$APP_NAME\"."
    echo "   Drag \"$APP_NAME\" into /Applications/ first, then re-run this."
    echo
    read -n 1 -s -r -p "按任意键关闭 / Press any key to close…"
    echo
    exit 1
  fi
  echo "→ 安装到 /Applications/  (Copying app into /Applications/)"
  if ! cp -R "$SRC_APP" "$DST_APP" 2>/dev/null; then
    echo "  /Applications/ 需要管理员密码 / requires admin password:"
    sudo cp -R "$SRC_APP" "$DST_APP" || {
      echo "❌ 复制失败 / copy failed."
      read -n 1 -s -r -p "按任意键关闭 / Press any key to close…"
      echo
      exit 1
    }
  fi
fi

# 2. 剥 quarantine（核心修复 / the actual fix）
echo "→ 剥离 com.apple.quarantine  (Stripping quarantine attribute)"
xattr -dr com.apple.quarantine "$DST_APP" 2>/dev/null || true

# 3. 重做 ad-hoc 签名。剥属性不会动文件内容，理论上不会破坏现有 ad-hoc
#    签名，但保险起见重签一次，免得某些场景下内核仍然走 cache 拒绝。
echo "→ 重做 ad-hoc 签名  (Re-applying ad-hoc signature)"
codesign --force --deep --sign - "$DST_APP" >/dev/null 2>&1 \
  && echo "  ✓ 重签成功 / re-signed OK" \
  || echo "  ⚠️  重签未通过，继续尝试启动 / re-sign failed, continuing anyway"

# 4. 启动
echo "→ 启动应用  (Launching app)"
open "$DST_APP" && launched="yes" || launched="no"

echo
if [ "$launched" = "yes" ]; then
  echo "✅ 完成！如果没看到窗口，到 Launchpad / Spotlight 搜 \"Open Island Feishu\"。"
  echo "✅ Done. If no window appeared, search \"Open Island Feishu\" in Launchpad."
else
  echo "❌ open 命令失败。请反馈以下 codesign 校验结果："
  echo "❌ open failed. Please report the codesign verify output below:"
  echo
  codesign --verify --deep --strict --verbose=2 "$DST_APP" 2>&1
fi
echo
read -n 1 -s -r -p "按任意键关闭 / Press any key to close…"
echo
