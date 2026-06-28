import Foundation
import OpenIslandCore

/// Session counts shown in the closed pill and opened header.
struct IslandSessionOverviewCounts: Equatable, Sendable {
    var total: Int
    var waiting: Int
    var running: Int
    var done: Int
    var idle: Int

    static let zero = IslandSessionOverviewCounts(total: 0, waiting: 0, running: 0, done: 0, idle: 0)
}

/// Aggregated closed-island snapshot derived from live sessions.
struct IslandClosedSummary: Equatable, Sendable {
    let taskCount: Int
    let agentNames: [String]
    let overview: IslandSessionOverviewCounts

    static func make(from sessions: [AgentSession]) -> IslandClosedSummary {
        var seen = Set<AgentTool>()
        var names: [String] = []
        for session in sessions {
            if seen.insert(session.tool).inserted {
                names.append(session.tool.displayName)
            }
        }
        return IslandClosedSummary(
            taskCount: sessions.count,
            agentNames: names,
            overview: .zero
        )
    }

    static func make(
        from sessions: [AgentSession],
        overview: IslandSessionOverviewCounts
    ) -> IslandClosedSummary {
        let base = make(from: sessions)
        return IslandClosedSummary(
            taskCount: base.taskCount,
            agentNames: base.agentNames,
            overview: overview
        )
    }

    /// Compact running / done / waiting line, e.g. "2运行·1完成".
    func taskBreakdownText(
        waitingLabel: String,
        runningLabel: String,
        doneLabel: String
    ) -> String? {
        guard taskCount > 0 else { return nil }

        var parts: [String] = []
        if overview.waiting > 0 { parts.append("\(overview.waiting)\(waitingLabel)") }
        if overview.running > 0 { parts.append("\(overview.running)\(runningLabel)") }
        if overview.done > 0 { parts.append("\(overview.done)\(doneLabel)") }
        if !parts.isEmpty { return parts.joined(separator: "·") }

        // Sessions exist but none fall into the live buckets — show agents or total.
        if let agents = agentsLine(maxAgents: 3) {
            return agents
        }
        return "\(taskCount)"
    }

    /// Right-slot summary: prefer task breakdown, then agent names.
    func rightSlotText(
        waitingLabel: String,
        runningLabel: String,
        doneLabel: String
    ) -> String? {
        guard taskCount > 0 else { return nil }
        return taskBreakdownText(
            waitingLabel: waitingLabel,
            runningLabel: runningLabel,
            doneLabel: doneLabel
        )
    }

    /// Center-label summary: keep short so the pill does not truncate to "...".
    func centerLabelText(idleText: String) -> String {
        guard taskCount > 0 else { return idleText }
        if let agents = agentsLine(maxAgents: 3) {
            return "\(taskCount) · \(agents.replacingOccurrences(of: "·", with: " "))"
        }
        return compactText(idleText: idleText)
    }

    /// Left-slot / center-label style: "3 · Codex Claude" or idle placeholder.
    func compactText(idleText: String) -> String {
        guard taskCount > 0 else { return idleText }
        if agentNames.isEmpty {
            return "\(taskCount)"
        }
        return "\(taskCount) · \(agentNames.joined(separator: " "))"
    }

    /// Center-label style with localized task noun: "3 tasks · Codex, Claude".
    func descriptiveText(taskNoun: String, idleText: String) -> String {
        guard taskCount > 0 else { return idleText }
        if agentNames.isEmpty {
            return "\(taskCount) \(taskNoun)"
        }
        return "\(taskCount) \(taskNoun) · \(agentNames.joined(separator: ", "))"
    }

    /// Right-slot style: agent abbreviations joined by middle dots.
    func agentsLine(maxAgents: Int = 4) -> String? {
        guard !agentNames.isEmpty else { return nil }
        if agentNames.count <= maxAgents {
            return agentNames.joined(separator: "·")
        }
        let head = agentNames.prefix(maxAgents).joined(separator: "·")
        return "\(head)+"
    }
}
