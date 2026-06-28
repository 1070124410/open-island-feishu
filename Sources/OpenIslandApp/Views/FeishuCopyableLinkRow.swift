import AppKit
import SwiftUI

/// 飞书设置页：可复制、可浏览器打开的链接行。
struct FeishuCopyableLinkRow: View {
    let urlString: String
    var copyLabel: String
    var openLabel: String

    @State private var copied = false

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                Text(urlString)
                    .font(.system(size: 10.5, design: .monospaced))
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    Button {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(urlString, forType: .string)
                        copied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copied = false
                        }
                    } label: {
                        Label(copyLabel, systemImage: copied ? "checkmark" : "doc.on.doc")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .foregroundStyle(copied ? .green : .primary)

                    if let url = URL(string: urlString) {
                        Button(openLabel) {
                            NSWorkspace.shared.open(url)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }
}

/// 简短错误说明 + 可选链接操作区。
struct FeishuActionableMessageView: View {
    let presentation: FeishuDisplayedMessage
    var style: Style = .error
    var copyLabel: String
    var openLabel: String

    enum Style {
        case error
        case secondary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(presentation.summary)
                .font(.caption)
                .foregroundStyle(style == .error ? .red : .secondary)
                .fixedSize(horizontal: false, vertical: true)

            if let url = presentation.actionURL {
                FeishuCopyableLinkRow(
                    urlString: url.absoluteString,
                    copyLabel: copyLabel,
                    openLabel: openLabel
                )
            }
        }
    }
}
