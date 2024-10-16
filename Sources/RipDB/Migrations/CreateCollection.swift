import Fluent

struct CreateCollection: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("collections")
            .id()
            .field("name", .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("collections").delete()
    }
}
