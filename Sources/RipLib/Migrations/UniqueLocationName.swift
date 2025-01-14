import Fluent

public struct UniqueLocationName: AsyncMigration {
    public func prepare(on database: Database) async throws {
        try await database.schema("locations")
            .unique(on: "name")
            .update()
    }

    public func revert(on database: Database) async throws {
        try await database.schema("locations")
            .deleteUnique(on: "name")
            .update()
    }
}
