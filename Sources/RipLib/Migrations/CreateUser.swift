import Fluent

public struct CreateUser: AsyncMigration {
    public func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("name", .string, .required)
            .field("password", .data, .required)
            .field("salt", .uuid, .required)
            .unique(on: "name")
            .create()
    }

    public func revert(on database: Database) async throws {
        try await database.schema("users").delete()
    }
}
