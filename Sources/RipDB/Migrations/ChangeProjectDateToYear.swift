import Fluent

struct ChangeProjectDateToYear: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("projects")
            .deleteField("release_date")
            .field("release_year", .int, .required)
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema("projects")
            .deleteField("release_year")
            .field("release_date", .date, .required)
            .update()
    }
}

// DB8320CE-5839-4BD4-8D11-5E5E2918931A
