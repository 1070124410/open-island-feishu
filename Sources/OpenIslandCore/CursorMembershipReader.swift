import Foundation
import SQLite3

/// Reads Cursor IDE subscription tier from the local VS Code state database.
/// Keys observed in Cursor 3.x: `cursorAuth/stripeMembershipType` (e.g. "pro").
public struct CursorMembershipSnapshot: Equatable, Sendable {
    public var membershipType: String
    public var subscriptionStatus: String?

    public init(membershipType: String, subscriptionStatus: String? = nil) {
        self.membershipType = membershipType
        self.subscriptionStatus = subscriptionStatus
    }

    /// Human-readable plan label for island UI (e.g. "Pro").
    public var displayPlanLabel: String {
        membershipType
            .replacingOccurrences(of: "_", with: " ")
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}

public enum CursorMembershipReader {
    public static func defaultDatabasePath() -> String {
        NSHomeDirectory() + "/Library/Application Support/Cursor/User/globalStorage/state.vscdb"
    }

    public static func load(databasePath: String = defaultDatabasePath()) -> CursorMembershipSnapshot? {
        guard FileManager.default.fileExists(atPath: databasePath),
              let membershipType = stringValue(
                  forKey: "cursorAuth/stripeMembershipType",
                  databasePath: databasePath
              )?.trimmingCharacters(in: .whitespacesAndNewlines),
              !membershipType.isEmpty else {
            return nil
        }

        let status = stringValue(
            forKey: "cursorAuth/stripeSubscriptionStatus",
            databasePath: databasePath
        )?.trimmingCharacters(in: .whitespacesAndNewlines)

        return CursorMembershipSnapshot(
            membershipType: membershipType,
            subscriptionStatus: status?.isEmpty == false ? status : nil
        )
    }

    private static func stringValue(forKey key: String, databasePath: String) -> String? {
        var db: OpaquePointer?
        let flags = SQLITE_OPEN_READONLY | SQLITE_OPEN_NOMUTEX
        guard sqlite3_open_v2(databasePath, &db, flags, nil) == SQLITE_OK,
              let db else {
            if db != nil { sqlite3_close(db) }
            return nil
        }
        defer { sqlite3_close(db) }

        sqlite3_busy_timeout(db, 60)

        let sql = "SELECT value FROM ItemTable WHERE key = ? LIMIT 1;"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK,
              let stmt else {
            return nil
        }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, key, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        guard sqlite3_step(stmt) == SQLITE_ROW,
              let cString = sqlite3_column_text(stmt, 0) else {
            return nil
        }

        return String(cString: cString)
    }
}
