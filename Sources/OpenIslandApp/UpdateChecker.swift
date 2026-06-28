import Combine
import Foundation
import Sparkle

/// Wraps Sparkle's `SPUUpdater` to provide observable update state for SwiftUI.
///
/// Sparkle handles the full lifecycle: checking for updates, downloading,
/// extracting, replacing the app bundle, and relaunching.
/// Feishu integration builds skip Sparkle — upstream updates would remove the fork.
@MainActor
@Observable
final class UpdateChecker: NSObject {
    static let releasesURL = URL(string: "https://github.com/1070124410/open-island-feishu/releases")!

    /// This fork ships as **Open Island Feishu** with bundle id `app.openisland.feishu`.
    static var isFeishuIntegrationBuild: Bool {
        if Bundle.main.bundleIdentifier == "app.openisland.feishu" {
            return true
        }
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return false
        }
        return version.localizedCaseInsensitiveContains("-feishu")
    }

    private(set) var canCheckForUpdates = false
    private(set) var hasUpdate = false
    private(set) var latestVersion: String?
    private(set) var updatesDisabled = false

    @ObservationIgnored
    private var updaterController: SPUStandardUpdaterController!

    @ObservationIgnored
    private var cancellable: AnyCancellable?

    override init() {
        super.init()
        updatesDisabled = Self.isFeishuIntegrationBuild
        updaterController = SPUStandardUpdaterController(
            startingUpdater: false,
            updaterDelegate: self,
            userDriverDelegate: nil
        )
    }

    /// Start Sparkle's automatic update checking schedule.
    /// Call once after app launch.
    func startIfNeeded() {
        if updatesDisabled {
            print("[UpdateChecker] skipped — Feishu integration build must not auto-update from upstream appcast")
            return
        }

        #if DEBUG
        print("[UpdateChecker] skipped in DEBUG build")
        return
        #else
        let updater = updaterController.updater
        updater.automaticallyChecksForUpdates = true
        updater.updateCheckInterval = 60 * 60 // 1 hour
        updater.automaticallyDownloadsUpdates = false

        do {
            try updater.start()
        } catch {
            print("[UpdateChecker] Failed to start Sparkle updater: \(error)")
        }

        cancellable = updater.publisher(for: \.canCheckForUpdates)
            .receive(on: RunLoop.main)
            .sink { [weak self] value in
                self?.canCheckForUpdates = value
            }
        #endif
    }

    /// Manually trigger an update check (from Settings UI).
    func checkForUpdates() {
        guard !updatesDisabled else { return }
        updaterController.checkForUpdates(nil)
    }
}

// MARK: - SPUUpdaterDelegate

extension UpdateChecker: SPUUpdaterDelegate {
    nonisolated func allowedChannels(for updater: SPUUpdater) -> Set<String> {
        Set()
    }

    nonisolated func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        let version = item.displayVersionString
        Task { @MainActor in
            self.hasUpdate = true
            self.latestVersion = version
        }
    }

    nonisolated func updaterDidNotFindUpdate(_ updater: SPUUpdater, error: any Error) {
        Task { @MainActor in
            self.hasUpdate = false
            self.latestVersion = nil
        }
    }
}
