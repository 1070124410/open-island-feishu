import Foundation
import Observation

/// 飞书远程审批设置的状态与自动化操作（供 Settings Tab / 菜单栏使用）。
@MainActor
@Observable
final class FeishuSettingsModel {
    var status: FeishuAdminClient.Status?
    var hooks: [FeishuAdminClient.HookEntry] = []
    var isBusy = false
    var lastMessage = ""
    var lastError: String?

    // 表单草稿
    var draftAppID = ""
    var draftAppSecret = ""
    var draftOpenID = ""
    var draftContact = ""
    var draftEnabled = true
    var draftLocalTimeoutSec = 30.0
    var draftFeishuMaxWaitMin = 10.0
    var draftHookTimeoutHours = 24.0

    var probeState = "idle"
    var probeMessage = ""
    var probeHelpURL = ""

    private var probePollTask: Task<Void, Never>?

    var statusTitle: String {
        guard let status else { return "Feishu sidecar offline" }
        if !status.sidecarInstalled { return "Sidecar not installed" }
        if status.feishuConnected { return "Feishu connected" }
        if status.daemonReachable { return "Daemon running (Feishu pending)" }
        return "Daemon unreachable"
    }

    var statusSummary: String {
        status?.message ?? lastError ?? "Configure App ID / Secret / open_id to enable remote approval."
    }

    func statusTitleCompact(lang: LanguageManager) -> String {
        guard let status else { return lang.t("feishu.status.offline") }
        if !status.sidecarInstalled { return lang.t("feishu.status.noSidecar") }
        if status.feishuConnected { return lang.t("feishu.status.connected") }
        if status.daemonReachable { return lang.t("feishu.status.pending") }
        return lang.t("feishu.status.unreachable")
    }

    /// 新手引导各步是否完成（供 FeishuSetupGuideView 展示进度）。
    var guideStep1Done: Bool {
        guard let st = status else { return false }
        return st.sidecarInstalled && st.daemonReachable
    }

    var guideStep2Done: Bool {
        guard let st = status else { return false }
        return !st.appID.isEmpty && st.hasAppSecret && st.hasOpenID
    }

    var guideStep3Done: Bool {
        hooks.contains { $0.state != "absent" }
    }

    var guideStep4Done: Bool {
        guard status?.enabled == true else { return false }
        let active = hooks.filter { $0.state != "absent" }
        guard !active.isEmpty else { return false }
        return active.allSatisfy { $0.state == "already_wrapped" }
    }

    var guideStep5Done: Bool {
        status?.feishuConnected == true
    }

    var allGuideStepsDone: Bool {
        guideStep1Done && guideStep2Done && guideStep3Done && guideStep4Done && guideStep5Done
    }

    func hookStateLabel(_ state: String, lang: LanguageManager) -> String {
        switch state {
        case "already_wrapped":
            return lang.t("feishu.hookState.wrapped")
        case "injectable":
            return lang.t("feishu.hookState.injectable")
        case "absent":
            return lang.t("feishu.hookState.absent")
        default:
            return state
        }
    }

    func refresh() async {
        isBusy = true
        defer { isBusy = false }
        do {
            let st = try await FeishuAdminClient.fetchStatus()
            status = st
            draftAppID = st.appID
            draftEnabled = st.enabled
            draftLocalTimeoutSec = Double(st.localTimeoutMs) / 1000.0
            draftFeishuMaxWaitMin = Double(st.feishuMaxWaitMs) / 60_000.0
            draftHookTimeoutHours = Double(st.hookTimeoutMs) / 3_600_000.0
            if let id = st.openID, !id.isEmpty {
                draftOpenID = id
            } else if !st.hasOpenID {
                draftOpenID = ""
            }
            if let contact = st.resolveContact, !contact.isEmpty {
                draftContact = contact
            }
            hooks = (try? await FeishuAdminClient.listHooks()) ?? []
            lastError = nil
        } catch {
            status = nil
            lastError = (error as? FeishuAdminError)?.errorDescription ?? error.localizedDescription
        }
    }

    func saveCredentials() async {
        isBusy = true
        defer { isBusy = false }
        do {
            try await FeishuAdminClient.saveCredentials(.init(
                appID: draftAppID.trimmingCharacters(in: .whitespacesAndNewlines),
                appSecret: draftAppSecret,
                openID: draftOpenID.trimmingCharacters(in: .whitespacesAndNewlines),
                contact: draftContact.trimmingCharacters(in: .whitespacesAndNewlines)
            ))
            draftAppSecret = ""
            lastMessage = "Credentials saved"
            await refresh()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func saveBehavior() async {
        isBusy = true
        defer { isBusy = false }
        do {
            try await FeishuAdminClient.updateConfig(.init(
                enabled: draftEnabled,
                localTimeoutMs: Int(draftLocalTimeoutSec * 1000),
                feishuMaxWaitMs: Int(draftFeishuMaxWaitMin * 60_000),
                hookTimeoutMs: Int(draftHookTimeoutHours * 3_600_000)
            ))
            lastMessage = "Settings saved"
            await refresh()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func sendTestCard() async {
        isBusy = true
        defer { isBusy = false }
        do {
            let mid = try await FeishuAdminClient.sendTestCard()
            lastMessage = "Test card sent: \(mid)"
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    func toggleMute() async {
        isBusy = true
        defer { isBusy = false }
        do {
            if status?.muted == true {
                try await FeishuAdminClient.unmute()
                lastMessage = "Feishu unmuted"
            } else {
                try await FeishuAdminClient.mute(hours: 1)
                lastMessage = "Feishu muted for 1 hour"
            }
            await refresh()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func startProbeOpenID() {
        probePollTask?.cancel()
        probePollTask = Task {
            isBusy = true
            defer { isBusy = false }
            probeState = "running"
            probeMessage = "正在通过飞书 API 解析 open_id…"
            probeHelpURL = ""
            lastError = nil
            do {
                try await FeishuAdminClient.saveCredentials(.init(
                    appID: draftAppID.trimmingCharacters(in: .whitespacesAndNewlines),
                    appSecret: draftAppSecret,
                    openID: draftOpenID.trimmingCharacters(in: .whitespacesAndNewlines)
                ))
                draftAppSecret = ""

                let appID = draftAppID.trimmingCharacters(in: .whitespacesAndNewlines)
                let contact = draftContact.trimmingCharacters(in: .whitespacesAndNewlines)
                let st = try await FeishuAdminClient.startProbeOpenID(
                    appID: appID.isEmpty ? nil : appID,
                    appSecret: nil,
                    contact: contact.isEmpty ? nil : contact
                )
                probeState = st.state
                probeMessage = st.message ?? ""
                probeHelpURL = st.helpURL ?? ""
                if st.state == "done", let id = st.openID, !id.isEmpty {
                    draftOpenID = id
                    lastMessage = "已获取 open_id"
                    await refresh()
                    return
                }
                if st.state == "error" {
                    lastError = st.message
                    probeHelpURL = st.helpURL ?? ""
                    return
                }
                await pollProbe()
            } catch {
                lastError = error.localizedDescription
                probeState = "error"
                probeMessage = error.localizedDescription
            }
        }
    }

    private func pollProbe() async {
        for _ in 0 ..< 15 {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            if let st = try? await FeishuAdminClient.probeStatus() {
                probeState = st.state
                probeMessage = st.message ?? ""
                probeHelpURL = st.helpURL ?? ""
                if st.state == "done", let id = st.openID, !id.isEmpty {
                    draftOpenID = id
                    lastMessage = "已获取 open_id"
                    await refresh()
                    return
                }
                if st.state == "error" {
                    lastError = st.message
                    probeHelpURL = st.helpURL ?? ""
                    probeMessage = st.message ?? "探测失败"
                    return
                }
            }
        }
    }

    func injectAllHooks() async {
        isBusy = true
        defer { isBusy = false }
        do {
            let injectable = hooks.filter { $0.state == "injectable" }.map(\.source)
            let msg = try await FeishuAdminClient.injectHooks(sources: injectable)
            lastMessage = msg
            await refresh()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func installSidecarIfNeeded() async {
        let script = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("open-island-feishu/scripts/install.sh")
        guard FileManager.default.fileExists(atPath: script.path) else {
            lastError = "未找到 ~/open-island-feishu/scripts/install.sh"
            return
        }
        isBusy = true
        defer { isBusy = false }
        do {
            let proc = Process()
            proc.executableURL = URL(fileURLWithPath: "/bin/zsh")
            proc.arguments = ["-lc", "printf 'all\\n' | '\(script.path)'"]
            let pipe = Pipe()
            proc.standardOutput = pipe
            proc.standardError = pipe
            try proc.run()
            proc.waitUntilExit()
            let out = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            if proc.terminationStatus != 0 {
                lastError = out
            } else {
                lastMessage = "Sidecar installed"
                await refresh()
            }
        } catch {
            lastError = error.localizedDescription
        }
    }
}
