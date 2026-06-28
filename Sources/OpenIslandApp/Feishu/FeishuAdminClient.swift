import Foundation

/// HTTP 客户端：与本地 feishu-bridged Admin API 通信（127.0.0.1:8742）。
enum FeishuAdminClient {
    static let baseURL = URL(string: "http://127.0.0.1:8742")!

    struct Status: Codable, Sendable {
        var version: String
        var daemonReachable: Bool
        var feishuConnected: Bool
        var enabled: Bool
        var muted: Bool
        var muteUntil: String?
        var appID: String
        var hasAppSecret: Bool
        var hasOpenID: Bool
        var openID: String?
        var openIDHash: String
        var resolveContact: String?
        var localTimeoutMs: Int
        var feishuMaxWaitMs: Int
        var hookTimeoutMs: Int
        var sockPath: String
        var adminAddr: String
        var sidecarInstalled: Bool
        var message: String?

        enum CodingKeys: String, CodingKey {
            case version
            case daemonReachable = "daemon_reachable"
            case feishuConnected = "feishu_connected"
            case enabled, muted
            case muteUntil = "mute_until"
            case appID = "app_id"
            case hasAppSecret = "has_app_secret"
            case hasOpenID = "has_open_id"
            case openID = "open_id"
            case openIDHash = "open_id_hash"
            case resolveContact = "resolve_contact"
            case localTimeoutMs = "local_timeout_ms"
            case feishuMaxWaitMs = "feishu_max_wait_ms"
            case hookTimeoutMs = "hook_timeout_ms"
            case sockPath = "sock_path"
            case adminAddr = "admin_addr"
            case sidecarInstalled = "sidecar_installed"
            case message
        }
    }

    struct ActionResult: Codable, Sendable {
        var ok: Bool
        var message: String?
    }

    struct ConfigUpdate: Codable, Sendable {
        var enabled: Bool?
        var localTimeoutMs: Int?
        var feishuMaxWaitMs: Int?
        var hookTimeoutMs: Int?

        enum CodingKeys: String, CodingKey {
            case enabled
            case localTimeoutMs = "local_timeout_ms"
            case feishuMaxWaitMs = "feishu_max_wait_ms"
            case hookTimeoutMs = "hook_timeout_ms"
        }
    }

    struct Credentials: Codable, Sendable {
        var appID: String
        var appSecret: String
        var openID: String
        var contact: String?

        enum CodingKeys: String, CodingKey {
            case appID = "app_id"
            case appSecret = "app_secret"
            case openID = "open_id"
            case contact
        }
    }

    struct HookEntry: Codable, Sendable, Identifiable {
        var source: String
        var state: String
        var count: Int
        var path: String
        var id: String { source }
    }

    struct HooksList: Codable, Sendable {
        var entries: [HookEntry]
    }

    struct ProbeStatus: Codable, Sendable {
        var state: String
        var openID: String?
        var message: String?
        var helpURL: String?

        enum CodingKeys: String, CodingKey {
            case state
            case openID = "open_id"
            case message
            case helpURL = "help_url"
        }
    }

    static func fetchStatus() async throws -> Status {
        try await get("/api/v1/status")
    }

    static func updateConfig(_ update: ConfigUpdate) async throws {
        let _: ActionResult = try await put("/api/v1/config", body: update)
    }

    static func saveCredentials(_ creds: Credentials) async throws {
        let _: ActionResult = try await put("/api/v1/credentials", body: creds)
    }

    static func sendTestCard() async throws -> String {
        let result: ActionResult = try await post("/api/v1/actions/test")
        return result.message ?? "ok"
    }

    static func mute(hours: Double = 1) async throws {
        struct Body: Encodable { var hours: Double }
        let _: ActionResult = try await post("/api/v1/actions/mute", body: Body(hours: hours))
    }

    static func unmute() async throws {
        let _: ActionResult = try await post("/api/v1/actions/unmute")
    }

    static func startProbeOpenID(appID: String? = nil, appSecret: String? = nil, contact: String? = nil) async throws -> ProbeStatus {
        struct Body: Encodable {
            var appID: String?
            var appSecret: String?
            var contact: String?

            enum CodingKeys: String, CodingKey {
                case appID = "app_id"
                case appSecret = "app_secret"
                case contact
            }
        }
        return try await post("/api/v1/actions/probe-open-id/start", body: Body(appID: appID, appSecret: appSecret, contact: contact))
    }

    static func probeStatus() async throws -> ProbeStatus {
        try await get("/api/v1/actions/probe-open-id")
    }

    static func listHooks() async throws -> [HookEntry] {
        let list: HooksList = try await get("/api/v1/hooks")
        return list.entries
    }

    static func injectHooks(sources: [String] = []) async throws -> String {
        struct Body: Encodable { var sources: [String] }
        let result: ActionResult = try await post("/api/v1/hooks/inject", body: Body(sources: sources))
        return result.message ?? "ok"
    }

    // MARK: - HTTP helpers

    private static func url(_ path: String) -> URL {
        URL(string: path.hasPrefix("/") ? path : "/\(path)", relativeTo: baseURL)!
    }

    private static func get<T: Decodable>(_ path: String) async throws -> T {
        var req = URLRequest(url: url(path))
        req.httpMethod = "GET"
        return try await decode(perform(req))
    }

    private static func put<B: Encodable, T: Decodable>(_ path: String, body: B) async throws -> T {
        var req = URLRequest(url: url(path))
        req.httpMethod = "PUT"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(body)
        return try await decode(perform(req))
    }

    private static func post<T: Decodable>(_ path: String) async throws -> T {
        var req = URLRequest(url: url(path))
        req.httpMethod = "POST"
        return try await decode(perform(req))
    }

    private static func post<B: Encodable, T: Decodable>(_ path: String, body: B) async throws -> T {
        var req = URLRequest(url: url(path))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(body)
        return try await decode(perform(req))
    }

    private static func perform(_ request: URLRequest) async throws -> (Data, URLResponse) {
        try await URLSession.shared.data(for: request)
    }

    private static func decode<T: Decodable>(_ pair: (Data, URLResponse)) throws -> T {
        let (data, response) = pair
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200 ..< 300).contains(http.statusCode) else {
            if let err = try? JSONDecoder().decode(ActionResult.self, from: data), let msg = err.message {
                throw FeishuAdminError.server(msg)
            }
            throw FeishuAdminError.server("HTTP \(http.statusCode)")
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}

enum FeishuAdminError: LocalizedError {
    case server(String)
    case unreachable

    var errorDescription: String? {
        switch self {
        case .server(let msg): msg
        case .unreachable: "无法连接 feishu-bridged Admin API（127.0.0.1:8742）。请先安装并启动 open-island-feishu sidecar。"
        }
    }
}
