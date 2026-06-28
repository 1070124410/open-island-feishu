import Foundation
import SQLite3
import Testing
@testable import OpenIslandCore

struct CursorMembershipReaderTests {
    @Test
    func loadReturnsNilWhenDatabaseMissing() {
        let path = NSTemporaryDirectory() + "missing-cursor-state-\(UUID().uuidString).vscdb"
        #expect(CursorMembershipReader.load(databasePath: path) == nil)
    }

    @Test
    func loadReadsMembershipTypeFromSQLite() throws {
        let path = NSTemporaryDirectory() + "cursor-state-\(UUID().uuidString).vscdb"
        defer { try? FileManager.default.removeItem(atPath: path) }

        var db: OpaquePointer?
        #expect(sqlite3_open(path, &db) == SQLITE_OK)
        guard let db else { return }
        defer { sqlite3_close(db) }

        #expect(sqlite3_exec(db, "CREATE TABLE ItemTable (key TEXT PRIMARY KEY, value TEXT);", nil, nil, nil) == SQLITE_OK)
        let insert = """
        INSERT INTO ItemTable (key, value) VALUES
          ('cursorAuth/stripeMembershipType', 'pro'),
          ('cursorAuth/stripeSubscriptionStatus', 'active');
        """
        #expect(sqlite3_exec(db, insert, nil, nil, nil) == SQLITE_OK)

        let snapshot = CursorMembershipReader.load(databasePath: path)
        #expect(snapshot?.membershipType == "pro")
        #expect(snapshot?.subscriptionStatus == "active")
        #expect(snapshot?.displayPlanLabel == "Pro")
    }
}
