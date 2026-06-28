import Foundation
import OpenIslandCore

struct UsageWindowPresentation: Identifiable {
    let id: String
    let label: String
    let usedPercentage: Double
    let resetsAt: Date?

    var roundedUsedPercentage: Int {
        Int(usedPercentage.rounded())
    }
}

struct UsageProviderPresentation: Identifiable {
    let id: String
    let title: String
    let planLabel: String?
    let windows: [UsageWindowPresentation]

    var peakWindow: UsageWindowPresentation? {
        windows.max { lhs, rhs in
            lhs.usedPercentage < rhs.usedPercentage
        }
    }

    var peakWindowLabel: String {
        peakWindow?.label ?? ""
    }

    var peakUsedPercentage: Double {
        peakWindow?.usedPercentage ?? 0
    }

    var peakUsagePercentage: Int {
        peakWindow?.roundedUsedPercentage ?? 0
    }

    var shortTitle: String {
        switch id {
        case "claude":
            "Cl"
        case "codex":
            "Cx"
        case "cursor":
            "Cu"
        default:
            String(title.prefix(2))
        }
    }
}

extension AppModel {
    /// Compact usage chips shown in the opened island header.
    func islandUsageProviders() -> [UsageProviderPresentation] {
        guard islandUsageDisplay == .compact else { return [] }

        var providers: [UsageProviderPresentation] = []

        if let claude = usageProvider(for: .claudeCode) {
            providers.append(claude)
        }
        if showCodexUsage, let codex = usageProvider(for: .codex) {
            providers.append(codex)
        }
        if let cursor = cursorUsageProvider() {
            providers.append(cursor)
        }

        return providers
    }

    func usageProvider(for tool: AgentTool) -> UsageProviderPresentation? {
        switch tool {
        case .claudeCode, .qoder, .qwenCode, .factory, .codebuddy, .kimiCLI:
            return claudeUsageProvider()
        case .codex:
            guard showCodexUsage else { return nil }
            return codexUsageProvider()
        case .cursor:
            return cursorUsageProvider()
        default:
            return nil
        }
    }

    func planLabel(for tool: AgentTool) -> String? {
        usageProvider(for: tool)?.planLabel
    }

    private func claudeUsageProvider() -> UsageProviderPresentation? {
        guard let snapshot = claudeUsageSnapshot,
              snapshot.isEmpty == false else {
            return nil
        }

        var windows: [UsageWindowPresentation] = []
        if let fiveHour = snapshot.fiveHour {
            windows.append(
                UsageWindowPresentation(
                    id: "claude-5h",
                    label: "5h",
                    usedPercentage: fiveHour.usedPercentage,
                    resetsAt: fiveHour.resetsAt
                )
            )
        }
        if let sevenDay = snapshot.sevenDay {
            windows.append(
                UsageWindowPresentation(
                    id: "claude-7d",
                    label: "7d",
                    usedPercentage: sevenDay.usedPercentage,
                    resetsAt: sevenDay.resetsAt
                )
            )
        }

        guard !windows.isEmpty else { return nil }

        let plan = claudeUsageInstalled ? lang.t("island.agentPlan.api") : nil
        return UsageProviderPresentation(
            id: "claude",
            title: "Claude",
            planLabel: plan,
            windows: windows
        )
    }

    private func codexUsageProvider() -> UsageProviderPresentation? {
        guard let snapshot = codexUsageSnapshot,
              snapshot.isEmpty == false else {
            return nil
        }

        let windows = snapshot.windows.map { window in
            UsageWindowPresentation(
                id: "codex-\(window.key)",
                label: window.label,
                usedPercentage: window.usedPercentage,
                resetsAt: window.resetsAt
            )
        }

        guard !windows.isEmpty else { return nil }

        let plan = formattedPlanLabel(snapshot.planType)
        return UsageProviderPresentation(
            id: "codex",
            title: "Codex",
            planLabel: plan,
            windows: windows
        )
    }

    private func cursorUsageProvider() -> UsageProviderPresentation? {
        guard let membership = CursorMembershipReader.load() else {
            return nil
        }

        return UsageProviderPresentation(
            id: "cursor",
            title: "Cursor",
            planLabel: membership.displayPlanLabel,
            windows: []
        )
    }

    private func formattedPlanLabel(_ raw: String?) -> String? {
        guard let raw = raw?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else {
            return nil
        }

        return raw
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}
