import SwiftUI

/// 飞书设置页顶部的新手引导：按顺序完成 sidecar → 凭据 → Hook → 注入 → 测试。
struct FeishuSetupGuideView: View {
    var lang: LanguageManager
    var feishu: FeishuSettingsModel
    var onOpenSetup: () -> Void
    var onInstallSidecar: () -> Void
    var onInjectHooks: () -> Void
    var onSendTest: () -> Void

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 14) {
                Text(lang.t("feishu.guide.intro"))
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                guideStep(
                    number: 1,
                    title: lang.t("feishu.guide.step1.title"),
                    detail: lang.t("feishu.guide.step1.detail"),
                    done: feishu.guideStep1Done
                ) {
                    if feishu.status?.sidecarInstalled != true {
                        Button(lang.t("feishu.installSidecar")) { onInstallSidecar() }
                            .disabled(feishu.isBusy)
                    }
                }

                guideStep(
                    number: 2,
                    title: lang.t("feishu.guide.step2.title"),
                    detail: lang.t("feishu.guide.step2.detail"),
                    done: feishu.guideStep2Done
                )

                guideStep(
                    number: 3,
                    title: lang.t("feishu.guide.step3.title"),
                    detail: lang.t("feishu.guide.step3.detail"),
                    done: feishu.guideStep3Done
                ) {
                    if !feishu.guideStep3Done {
                        Button(lang.t("feishu.guide.openSetup")) { onOpenSetup() }
                    }
                }

                guideStep(
                    number: 4,
                    title: lang.t("feishu.guide.step4.title"),
                    detail: lang.t("feishu.guide.step4.detail"),
                    done: feishu.guideStep4Done
                ) {
                    let injectable = feishu.hooks.filter { $0.state == "injectable" }
                    if !injectable.isEmpty {
                        Button(lang.t("feishu.injectHooks")) { onInjectHooks() }
                            .disabled(feishu.isBusy)
                    }
                }

                guideStep(
                    number: 5,
                    title: lang.t("feishu.guide.step5.title"),
                    detail: lang.t("feishu.guide.step5.detail"),
                    done: feishu.guideStep5Done
                ) {
                    Button(lang.t("feishu.sendTest")) { onSendTest() }
                        .disabled(feishu.isBusy || !feishu.guideStep2Done)
                }

                if feishu.allGuideStepsDone {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                        Text(lang.t("feishu.guide.allDone"))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 2)
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text(lang.t("feishu.section.guide"))
        }
    }

    @ViewBuilder
    private func guideStep(
        number: Int,
        title: String,
        detail: String,
        done: Bool,
        @ViewBuilder actions: () -> some View = { EmptyView() }
    ) -> some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
                    .fill(done ? Color.green.opacity(0.85) : Color.blue.opacity(0.75))
                    .frame(width: 22, height: 22)
                if done {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                } else {
                    Text("\(number)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
            .padding(.top, 1)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 12.5, weight: .semibold))
                Text(detail)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                actions()
            }
        }
    }
}
