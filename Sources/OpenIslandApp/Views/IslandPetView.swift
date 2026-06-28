import AppKit
import SwiftUI

/// Custom left-slot icon when `closedLeading == .pet` (UI: 自定义).
struct IslandPetView: View {
    let kind: IslandPetKind
    let emoji: String
    let customImagePath: String
    var textScrolling: Bool = false
    var textVisibleLength: Int = Self.defaultTextVisibleLength
    let activityMode: UnifiedBars.Mode
    let size: CGFloat

    @State private var pulse = false

    static let defaultTextVisibleLength = 5
    static let minTextVisibleLength = 2
    static let maxTextVisibleLength = 12

    static func clampedTextVisibleLength(_ value: Int) -> Int {
        if value < minTextVisibleLength { return defaultTextVisibleLength }
        return min(max(value, minTextVisibleLength), maxTextVisibleLength)
    }

    static func textSlotWidth(height: CGFloat, visibleLength: Int = defaultTextVisibleLength) -> CGFloat {
        let fontSize = height * 0.58
        let length = clampedTextVisibleLength(visibleLength)
        return fontSize * CGFloat(length) * 1.06
    }

    private var slotWidth: CGFloat {
        kind == .emoji ? Self.textSlotWidth(height: size, visibleLength: textVisibleLength) : size
    }

    var body: some View {
        ZStack {
            switch kind {
            case .scout:
                OpenIslandBrandMark(size: size * 1.35, tone: .paper)
            case .emoji:
                textContent
            case .custom:
                customImage
            }
        }
        .frame(width: slotWidth, height: size)
        .opacity(activityOpacity)
        .scaleEffect(activityScale)
        .animation(.easeInOut(duration: 0.35), value: activityMode)
        .modifier(IslandPetWaitingPulse(isActive: activityMode == .waiting, pulse: $pulse))
        .id(contentIdentity)
    }

    private var contentIdentity: String {
        "\(kind.rawValue)-\(emoji)-\(textScrolling)-\(textVisibleLength)-\(customImagePath)"
    }

    @ViewBuilder
    private var textContent: some View {
        let width = Self.textSlotWidth(height: size, visibleLength: textVisibleLength)
        if textScrolling {
            IslandMarqueeText(text: displayText, fontSize: textFontSize, frameWidth: width, frameHeight: size)
        } else {
            Text(displayText)
                .font(.system(size: textFontSize))
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(width: width, height: size, alignment: .center)
        }
    }

    private var displayText: String {
        let trimmed = emoji.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "🐾" : trimmed
    }

    private var textFontSize: CGFloat {
        let length = displayText.count
        if textScrolling { return size * 0.58 }
        if length <= 1 { return size * 0.92 }
        if length <= 2 { return size * 0.72 }
        return size * 0.58
    }

    /// Text for the custom text slot. Static mode caps at visible length; scrolling allows more.
    static func sanitizedPetText(
        _ value: String,
        scrollingEnabled: Bool = false,
        visibleLength: Int = defaultTextVisibleLength
    ) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }
        let limit = scrollingEnabled ? 32 : clampedTextVisibleLength(visibleLength)
        var result = ""
        for character in trimmed {
            result.append(character)
            if result.count >= limit { break }
        }
        return result
    }

    @ViewBuilder
    private var customImage: some View {
        if let image = loadedCustomImage {
            Image(nsImage: image)
                .resizable()
                .interpolation(.high)
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
                .id(customImagePath)
        } else {
            Image(systemName: "photo")
                .font(.system(size: size * 0.45, weight: .semibold))
                .foregroundStyle(V6Palette.paper.opacity(0.45))
        }
    }

    private var loadedCustomImage: NSImage? {
        let path = customImagePath.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !path.isEmpty else { return nil }
        return NSImage(contentsOfFile: path)
    }

    private var activityOpacity: Double {
        switch activityMode {
        case .idle:    return 0.72
        case .running: return 1.0
        case .waiting: return pulse ? 1.0 : 0.42
        }
    }

    private var activityScale: CGFloat {
        activityMode == .running ? 1.04 : 1.0
    }

    static func intrinsicWidth(size: CGFloat, kind: IslandPetKind = .scout, textVisibleLength: Int = defaultTextVisibleLength) -> CGFloat {
        kind == .emoji ? textSlotWidth(height: size, visibleLength: textVisibleLength) : size
    }
}

/// Horizontal marquee: one-way left-to-right loop (reset and repeat, no bounce).
private struct IslandMarqueeText: View {
    let text: String
    let fontSize: CGFloat
    let frameWidth: CGFloat
    let frameHeight: CGFloat

    @State private var textWidth: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var marqueeGeneration: Int = 0

    var body: some View {
        ZStack(alignment: .leading) {
            Text(text)
                .font(.system(size: fontSize))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear { updateTextWidth(proxy.size.width) }
                            .onChange(of: text) { _, _ in updateTextWidth(proxy.size.width) }
                            .onChange(of: proxy.size.width) { _, width in updateTextWidth(width) }
                    }
                )
                .offset(x: scrollOffset)
        }
        .frame(width: frameWidth, height: frameHeight, alignment: .leading)
        .clipped()
        .onAppear { restartMarquee() }
        .onChange(of: text) { _, _ in restartMarquee() }
        .onChange(of: textWidth) { _, _ in restartMarquee() }
    }

    private func updateTextWidth(_ width: CGFloat) {
        guard width > 0 else { return }
        textWidth = width
    }

    /// Text enters from the left edge and exits right; then loops from the start.
    private func restartMarquee() {
        marqueeGeneration &+= 1
        let generation = marqueeGeneration
        scrollOffset = -textWidth

        guard textWidth > 0 else { return }

        let endOffset = frameWidth
        let duration = max(2.0, Double(textWidth + frameWidth) * 0.055)

        DispatchQueue.main.async {
            guard generation == marqueeGeneration else { return }
            withAnimation(.linear(duration: duration)) {
                scrollOffset = endOffset
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                guard generation == marqueeGeneration else { return }
                scrollOffset = -textWidth
                restartMarquee()
            }
        }
    }
}

/// Breathing pulse used when an agent is waiting for approval/input.
private struct IslandPetWaitingPulse: ViewModifier {
    let isActive: Bool
    @Binding var pulse: Bool

    func body(content: Content) -> some View {
        content
            .onAppear { startPulseIfNeeded() }
            .onChange(of: isActive) { _, active in
                if active {
                    startPulseIfNeeded()
                } else {
                    pulse = false
                }
            }
    }

    private func startPulseIfNeeded() {
        guard isActive else { return }
        withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
            pulse = true
        }
    }
}
