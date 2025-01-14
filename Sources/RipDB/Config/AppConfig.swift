import RipLib

public struct AppConfig: Sendable, Hashable, Codable {
    public var environment: ParsableEnvironment = .development
    public var database: PostgresDBLocation
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.environment = try container.decodeIfPresent(ParsableEnvironment.self, forKey: .environment) ?? .development
        self.database = try container.decode(PostgresDBLocation.self, forKey: .database)
    }
}
