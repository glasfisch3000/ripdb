import Fluent

struct CreateVideo: AsyncMigration {
    func prepare(on database: Database) async throws {
        let videoType = try await database.enum("video_type")
            .case("main")
            .case("episode")
            .case("extra")
            .case("trailer")
            .case("advertisement")
            .create()
        
        try await database.schema("videos")
            .id()
            .field("name", .string, .required)
            .field("type", videoType, .required)
            .field("project", .uuid, .required, .references("projects", "id"))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("videos").delete()
        try await database.enum("video_type").delete()
    }
}
