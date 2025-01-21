public struct PostgresDBLocation: Sendable, Hashable, Codable {
    public var host: String
    public var port: UInt16
    public var user: String
    public var password: String
    public var database: String
}
