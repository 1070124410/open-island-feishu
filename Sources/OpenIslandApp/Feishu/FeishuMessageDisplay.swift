import Foundation

/// 将 sidecar / API 返回的长错误文案拆成「简短说明 + 可操作链接」。
struct FeishuDisplayedMessage: Equatable {
    var summary: String
    var actionURL: URL?

    /// 解析原始错误；优先使用 API 返回的 help_url，否则从正文提取或按 app_id 合成权限申请链接。
    static func parse(message: String, helpURL: String? = nil, appID: String? = nil) -> FeishuDisplayedMessage {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return FeishuDisplayedMessage(summary: "", actionURL: nil) }

        if let urlString = helpURL?.trimmingCharacters(in: .whitespacesAndNewlines),
           !urlString.isEmpty,
           let url = URL(string: urlString) {
            return FeishuDisplayedMessage(summary: trimmed, actionURL: url)
        }

        if let extracted = extractURL(from: trimmed) {
            let summary = stripURL(extracted, from: trimmed)
            return FeishuDisplayedMessage(
                summary: summary.isEmpty ? trimmed : summary,
                actionURL: URL(string: extracted)
            )
        }

        if trimmed.localizedCaseInsensitiveContains("contact:user.id:readonly"),
           let url = synthesizedContactScopeURL(appID: appID) {
            return FeishuDisplayedMessage(summary: trimmed, actionURL: url)
        }

        return FeishuDisplayedMessage(summary: trimmed, actionURL: nil)
    }

    private static func extractURL(from text: String) -> String? {
        let pattern = #"https?://[^\s）)]+"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex ..< text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              let urlRange = Range(match.range, in: text) else { return nil }
        return String(text[urlRange])
    }

    private static func stripURL(_ url: String, from text: String) -> String {
        text
            .replacingOccurrences(of: url, with: "")
            .replacingOccurrences(of: "点击链接申请并开通任一权限即可：", with: "")
            .replacingOccurrences(of: "（需开通 contact:user.id:readonly）", with: "")
            .replacingOccurrences(of: "(需开通 contact:user.id:readonly)", with: "")
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: "：:")))
    }

    private static func synthesizedContactScopeURL(appID: String?) -> URL? {
        let trimmed = appID?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let path = trimmed.isEmpty ? "https://open.feishu.cn/app" : "https://open.feishu.cn/app/\(trimmed)/auth"
        var components = URLComponents(string: path)
        components?.queryItems = [
            URLQueryItem(name: "q", value: "contact:user.id:readonly"),
            URLQueryItem(name: "op_from", value: "openapi"),
            URLQueryItem(name: "token_type", value: "tenant"),
        ]
        return components?.url
    }
}
