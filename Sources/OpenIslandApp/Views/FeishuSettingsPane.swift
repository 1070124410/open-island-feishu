import SwiftUI

/// Open Island 设置 → 飞书 Tab：凭据、超时、Hook 注入与测试。
struct FeishuSettingsPane: View {
    var model: AppModel
    private var feishu: FeishuSettingsModel { model.feishuSettings }
    private var lang: LanguageManager { model.lang }

    var body: some View {
        Form {
            FeishuSetupGuideView(
                lang: lang,
                feishu: feishu,
                onOpenSetup: { model.showOnboarding() },
                onInstallSidecar: { Task { await feishu.installSidecarIfNeeded() } },
                onInjectHooks: { Task { await feishu.injectAllHooks() } },
                onSendTest: { Task { await feishu.sendTestCard() } }
            )
            statusSection
            credentialsSection
            behaviorSection
            automationSection
            hooksSection
            actionsSection
        }
        .formStyle(.grouped)
        .navigationTitle(lang.t("settings.tab.feishu"))
        .task { await feishu.refresh() }
        .refreshable { await feishu.refresh() }
    }

    private var statusSection: some View {
        Section(lang.t("feishu.section.status")) {
            LabeledContent(lang.t("feishu.status.title"), value: statusHeadline)
            if let msg = feishu.lastError ?? feishu.status?.message, !msg.isEmpty {
                feishuMessageView(
                    message: msg,
                    helpURL: feishu.probeHelpURL,
                    style: .error
                )
            } else if !feishu.lastMessage.isEmpty {
                Text(feishu.lastMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let st = feishu.status {
                LabeledContent(lang.t("feishu.status.sidecar"), value: st.daemonReachable
                    ? lang.t("feishu.status.sidecar.up")
                    : lang.t("feishu.status.sidecar.down"))
                LabeledContent(lang.t("feishu.status.feishuLink"), value: st.feishuConnected
                    ? lang.t("feishu.status.feishuLink.up")
                    : lang.t("feishu.status.feishuLink.down"))
                if st.muted, let until = st.muteUntil {
                    LabeledContent(lang.t("feishu.mutedUntil"), value: until)
                }
            }
        }
    }

    private var statusHeadline: String {
        guard let st = feishu.status else { return lang.t("feishu.status.offline") }
        if !st.sidecarInstalled { return lang.t("feishu.status.noSidecar") }
        if st.feishuConnected { return lang.t("feishu.status.connected") }
        if st.daemonReachable { return lang.t("feishu.status.pending") }
        return lang.t("feishu.status.unreachable")
    }

    private var credentialsSection: some View {
        Section(lang.t("feishu.section.credentials")) {
            TextField(lang.t("feishu.appID"), text: Binding(
                get: { feishu.draftAppID },
                set: { feishu.draftAppID = $0 }
            ))
            VStack(alignment: .leading, spacing: 4) {
                SecureField(
                    lang.t("feishu.appSecret"),
                    text: Binding(
                        get: { feishu.draftAppSecret },
                        set: { feishu.draftAppSecret = $0 }
                    ),
                    prompt: Text(appSecretPrompt)
                )
                if feishu.status?.hasAppSecret == true, feishu.draftAppSecret.isEmpty {
                    Text(lang.t("feishu.appSecretSavedHint"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            TextField(lang.t("feishu.openID"), text: Binding(
                get: { feishu.draftOpenID },
                set: { feishu.draftOpenID = $0 }
            ))
            TextField(lang.t("feishu.contact"), text: Binding(
                get: { feishu.draftContact },
                set: { feishu.draftContact = $0 }
            ))
            Text(lang.t("feishu.contactHint"))
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Button(lang.t("feishu.probeOpenID")) {
                    feishu.startProbeOpenID()
                }
                .disabled(feishu.isBusy || feishu.draftAppID.isEmpty || feishu.draftContact.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                if feishu.probeState == "running" {
                    ProgressView().controlSize(.small)
                }
            }
            if !feishu.probeMessage.isEmpty {
                feishuMessageView(
                    message: feishu.probeMessage,
                    helpURL: feishu.probeHelpURL,
                    style: feishu.probeState == "error" ? .error : .secondary
                )
            }
            Button(lang.t("feishu.saveCredentials")) {
                Task { await feishu.saveCredentials() }
            }
            .disabled(feishu.isBusy)
        }
    }

    @ViewBuilder
    private func feishuMessageView(
        message: String,
        helpURL: String,
        style: FeishuActionableMessageView.Style
    ) -> some View {
        let presentation = resolvedMessage(message: message, helpURL: helpURL)
        if presentation.actionURL != nil {
            FeishuActionableMessageView(
                presentation: presentation,
                style: style,
                copyLabel: lang.t("feishu.copyLink"),
                openLabel: lang.t("feishu.openLink")
            )
        } else {
            Text(presentation.summary)
                .font(.caption)
                .foregroundStyle(style == .error ? .red : .secondary)
        }
    }

    private func resolvedMessage(message: String, helpURL: String) -> FeishuDisplayedMessage {
        var presentation = FeishuDisplayedMessage.parse(
            message: message,
            helpURL: helpURL.isEmpty ? nil : helpURL,
            appID: feishu.draftAppID
        )
        if isContactScopeError(message) {
            presentation.summary = lang.t("feishu.error.contactScopeSummary")
        }
        return presentation
    }

    private func isContactScopeError(_ message: String) -> Bool {
        message.localizedCaseInsensitiveContains("contact:user.id:readonly") || message.contains("99991672")
    }

    private var appSecretPrompt: String {
        if !feishu.draftAppSecret.isEmpty { return lang.t("feishu.appSecretPlaceholder") }
        if feishu.status?.hasAppSecret == true { return lang.t("feishu.appSecretSaved") }
        return lang.t("feishu.appSecretPlaceholder")
    }

    private var behaviorSection: some View {
        Section(lang.t("feishu.section.behavior")) {
            Toggle(lang.t("feishu.enabled"), isOn: Binding(
                get: { feishu.draftEnabled },
                set: { feishu.draftEnabled = $0 }
            ))
            LabeledContent(lang.t("feishu.localTimeout")) {
                Stepper("\(Int(feishu.draftLocalTimeoutSec))s", value: Binding(
                    get: { feishu.draftLocalTimeoutSec },
                    set: { feishu.draftLocalTimeoutSec = $0 }
                ), in: 5 ... 120, step: 5)
            }
            LabeledContent(lang.t("feishu.feishuMaxWait")) {
                Stepper(String(format: "%.0f min", feishu.draftFeishuMaxWaitMin), value: Binding(
                    get: { feishu.draftFeishuMaxWaitMin },
                    set: { feishu.draftFeishuMaxWaitMin = $0 }
                ), in: 1 ... 120, step: 1)
            }
            LabeledContent(lang.t("feishu.hookTimeout")) {
                Stepper(String(format: "%.0f h", feishu.draftHookTimeoutHours), value: Binding(
                    get: { feishu.draftHookTimeoutHours },
                    set: { feishu.draftHookTimeoutHours = $0 }
                ), in: 1 ... 48, step: 1)
            }
            Button(lang.t("feishu.saveBehavior")) {
                Task { await feishu.saveBehavior() }
            }
            .disabled(feishu.isBusy)
        }
    }

    private var automationSection: some View {
        Section(lang.t("feishu.section.automation")) {
            if feishu.status?.sidecarInstalled != true {
                Button(lang.t("feishu.installSidecar")) {
                    Task { await feishu.installSidecarIfNeeded() }
                }
                .disabled(feishu.isBusy)
            }
            Button(lang.t("feishu.injectHooks")) {
                Task { await feishu.injectAllHooks() }
            }
            .disabled(feishu.isBusy || feishu.hooks.filter { $0.state == "injectable" }.isEmpty)
            Link(lang.t("feishu.openPlatformHelp"), destination: URL(string: "https://open.feishu.cn/app")!)
        }
    }

    private var hooksSection: some View {
        Section(lang.t("feishu.section.hooks")) {
            if feishu.hooks.isEmpty {
                Text(lang.t("feishu.hooksEmpty"))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(feishu.hooks.filter { $0.state != "absent" }) { hook in
                    HStack {
                        Text(hook.source)
                        Spacer()
                        Text(feishu.hookStateLabel(hook.state, lang: lang))
                            .font(.caption)
                            .foregroundStyle(hook.state == "already_wrapped" ? .green : .orange)
                    }
                }
            }
        }
    }

    private var actionsSection: some View {
        Section(lang.t("feishu.section.actions")) {
            Button(lang.t("feishu.sendTest")) {
                Task { await feishu.sendTestCard() }
            }
            .disabled(feishu.isBusy)
            Button(feishu.status?.muted == true ? lang.t("feishu.unmute") : lang.t("feishu.mute")) {
                Task { await feishu.toggleMute() }
            }
            .disabled(feishu.isBusy || feishu.status == nil)
            Button(lang.t("feishu.refresh")) {
                Task { await feishu.refresh() }
            }
            .disabled(feishu.isBusy)
        }
    }
}
