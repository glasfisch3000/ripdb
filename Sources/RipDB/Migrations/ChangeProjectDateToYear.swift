import Fluent

public struct ChangeProjectDateToYear: AsyncMigration {
    public func prepare(on database: Database) async throws {
        try await database.schema("projects")
            .deleteField("release_date")
            .field("release_year", .int, .required)
            .update()
    }

    public func revert(on database: Database) async throws {
        try await database.schema("projects")
            .deleteField("release_year")
            .field("release_date", .date, .required)
            .update()
    }
}
