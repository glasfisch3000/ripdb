import Fluent

struct UniqueLocationName: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("locations")
            .unique(on: "name")
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema("locations")
            .deleteUnique(on: "name")
            .update()
    }
}
