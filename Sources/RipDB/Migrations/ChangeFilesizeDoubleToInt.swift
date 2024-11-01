import Fluent

struct ChangeFilesizeDoubleToInt: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("locations")
            .updateField("capacity", .int)
            .update()
        
        try await database.schema("files")
            .updateField("size", .int)
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema("locations")
            .updateField("capacity", .double)
            .update()
        
        try await database.schema("files")
            .updateField("size", .double)
            .update()
    }
}

// DB8320CE-5839-4BD4-8D11-5E5E2918931A
