import Fluent

public struct CreateCollection: AsyncMigration {
    public func prepare(on database: Database) async throws {
        try await database.schema("collections")
            .id()
            .field("name", .string, .required)
            .create()
    }

    public func revert(on database: Database) async throws {
        try await database.schema("collections").delete()
    }
}
