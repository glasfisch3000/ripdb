import Fluent

struct CreateFile: AsyncMigration {
    func prepare(on database: Database) async throws {
        let fileResolution = try await database.enum("file_resolution")
            .case("SD")
            .case("HD")
            .case("FHD")
            .case("UHD")
            .create()
        
        try await database.schema("files")
            .id()
            .field("resolution", fileResolution, .required)
            .field("is_3d", .bool, .required)
            .field("size", .double, .required)
            .field("content_hash_sha256", .data, .required)
            .field("video", .uuid, .required, .references("videos", "id"))
            .field("location", .uuid, .required, .references("locations", "id"))
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.enum("file_resolution").delete()
        try await database.schema("files").delete()
    }
}
