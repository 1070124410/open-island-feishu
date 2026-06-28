import Foundation

/// Per-user data locations for Open Island Feishu.
///
/// Uses `OpenIslandFeishu` (not upstream `OpenIsland`) so this app can be installed
/// alongside official [Open Island](https://github.com/Octane0411/open-vibe-island)
/// without sharing bridge sockets or hook binaries.
public enum OpenIslandPaths {
    public static let applicationSupportName = "OpenIslandFeishu"

    public static func applicationSupportURL(fileManager: FileManager = .default) -> URL {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSHomeDirectory())
                .appendingPathComponent("Library/Application Support", isDirectory: true)
        return base.appendingPathComponent(applicationSupportName, isDirectory: true)
    }

    public static var bridgeSocketURL: URL {
        applicationSupportURL().appendingPathComponent("bridge.sock")
    }
}
