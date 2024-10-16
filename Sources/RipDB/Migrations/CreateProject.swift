import Fluent

struct CreateProject: AsyncMigration {
    func prepare(on database: Database) async throws {
        let projectType = try await database.enum("project_type")
            .case("season")
            .case("movie")
            .create()
        
        try await database.schema("projects")
            .id()
            .field("name", .string, .required)
            .field("type", projectType, .required)
            .field("release_date", .date, .required)
            .field("collection", .uuid, .references("collections", "id"))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.enum("project_type").delete()
        try await database.schema("projects").delete()
    }
}
