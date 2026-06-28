import AppKit
import CoreGraphics
import Foundation
import OpenIslandCore

enum NotchStatus: Equatable {
    case closed
    case opened
    case popping
}

enum NotchOpenReason: Equatable {
    case click
    case hover
    case notification
    case boot
}

enum TrackedEventIngress {
    case bridge
    case rollout
}

// MARK: - v6 island preferences

/// What the closed island renders in the right slot. Chosen in the
/// Personalization tab; the pill layout only varies by content width.
enum IslandRightSlot: String, CaseIterable, Identifiable, Sendable {
    case count   // "×N" badge
    case agents  // colored dot stack, one per active agent tool
    case summary // compact text: task count + agent names
    case none    // pill collapses — useful if you just want the bars

    var id: String { rawValue }
}

/// What the closed island renders in the left slot (replacing the default
/// UnifiedBars glyph when set to custom content or summary).
enum IslandClosedLeading: String, CaseIterable, Identifiable, Sendable {
    case activityBars // animated three-bar activity glyph (default)
    case pet          // scout / text / uploaded image (UI: 自定义)
    case summary      // compact task + agent summary text

    var id: String { rawValue }
}

/// Custom left-slot content source (persisted key remains `petKind`).
enum IslandPetKind: String, CaseIterable, Identifiable, Sendable {
    case scout  // Open Island brand mark
    case emoji  // short text or emoji (UI: 文本)
    case custom // user-selected image file (UI: 自己上传的图片)

    var id: String { rawValue }
}

/// What the closed island renders in the center label (external displays
/// only — on MacBook the physical notch covers this space so we suppress
/// the label regardless).
enum IslandCenterLabel: String, CaseIterable, Identifiable, Sendable {
    case sessionName  // e.g. "open-island"
    case agentAction  // e.g. "Claude · editing"
    case summary      // e.g. "3 tasks · Codex, Claude"
    case off

    var id: String { rawValue }
}

// MARK: - v8 island preferences

enum IslandAppearanceDisplayProfile: String, CaseIterable, Identifiable, Sendable {
    case notch
    case topBar

    var id: String { rawValue }
}

struct IslandAppearancePreferences: Equatable, Sendable {
    var closedLeading: IslandClosedLeading = .activityBars
    var petKind: IslandPetKind = .scout
    var petEmoji: String = "🐾"
    var petTextScrolling: Bool = false
    /// Visible character slots for the custom text field on the closed island (2…12).
    var petTextVisibleLength: Int = 5
    var petCustomImagePath: String = ""
    var rightSlot: IslandRightSlot = .count
    var centerLabel: IslandCenterLabel = .agentAction
    var usageDisplay: IslandUsageDisplay = .compact
    var sessionStateIndicator: IslandSessionStateIndicator = .animatedDot
    var sessionGroup: IslandSessionGroup = .agent
    var sessionSort: IslandSessionSort = .attention
    var completedStaleThreshold: IslandCompletedStaleThreshold = .fiveMinutes
}

enum IslandUsageDisplay: String, CaseIterable, Identifiable, Sendable {
    case hidden
    case compact

    var id: String { rawValue }
}

enum IslandSessionStateIndicator: String, CaseIterable, Identifiable, Sendable {
    case animatedDot
    case bar
    case glyph
    case tint

    var id: String { rawValue }
}

enum IslandSessionGroup: String, CaseIterable, Identifiable, Sendable {
    case none
    case state
    case agent
    case project

    var id: String { rawValue }
}

enum IslandSessionSort: String, CaseIterable, Identifiable, Sendable {
    case attention
    case lastUpdate

    var id: String { rawValue }
}

enum IslandCompletedStaleThreshold: String, CaseIterable, Identifiable, Sendable {
    case twoMinutes
    case fiveMinutes
    case tenMinutes
    case twentyMinutes
    case never

    var id: String { rawValue }

    var seconds: TimeInterval {
        switch self {
        case .twoMinutes:    return 2 * 60
        case .fiveMinutes:   return 5 * 60
        case .tenMinutes:    return 10 * 60
        case .twentyMinutes: return 20 * 60
        case .never:         return .infinity
        }
    }
}

struct IslandSessionSection: Identifiable {
    let id: String
    let title: String
    let sessions: [AgentSession]
}
