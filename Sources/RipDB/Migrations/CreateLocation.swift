import Fluent

public struct CreateLocation: AsyncMigration {
    public func prepare(on database: Database) async throws {
        try await database.schema("locations")
            .id()
            .field("name", .string, .required)
            .field("capacity", .double)
            .create()
    }

    public func revert(on database: Database) async throws {
        try await database.schema("locations").delete()
    }
}
