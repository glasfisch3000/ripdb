import Fluent

struct CreateLocation: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("locations")
            .id()
            .field("name", .string, .required)
            .field("capacity", .double)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("locations").delete()
    }
}
