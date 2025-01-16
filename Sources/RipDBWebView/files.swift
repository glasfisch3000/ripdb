import Vapor
import Fluent
import RipLib

@Sendable
func filesList(request req: Request) async throws -> View {
    let files = try await File.query(on: req.db)
        .with(\.$location)
        .with(\.$video) {
            $0.with(\.$project)
        }
        .join(parent: \.$location)
        .join(parent: \.$video)
        .join(from: Video.self, parent: \.$project)
        .sort(Project.self, \.$name)
        .sort(Video.self, \.$type)
        .sort(Video.self, \.$name)
        .sort(\.$resolution)
        .sort(\.$is3D)
        .sort(Location.self, \.$name)
        .sort(\.$size)
        .all()
    
    let context = FilesContext(files: files.map { $0.toWebDTO() })
    return try await req.view.render("files", context)
}

@Sendable
func filesGet(request req: Request) async throws -> View {
    guard let id = req.parameters.get("id", as: UUID.self) else {
        return try await req.view.render("invalidID", InvalidIDContext(type: "file", sidebarLocation: .files))
    }
    
    guard let file = try await File.find(id, on: req.db) else {
        return try await req.view.render("notFound", NotFoundContext(type: "file", id: id, sidebarLocation: .files))
    }
    
    try await file.$location.load(on: req.db)
    _ = try await file.$video.get(on: req.db).flatMap { video in
        video.$project.load(on: req.db)
    }
    .get()
    
    let context = FilesContext.Singular(id: id, file: file.toWebDTO())
    return try await req.view.render("file", context)
}

struct FilesContext: Encodable {
    let sidebarLocation: SidebarLocation = .files
    var files: [RipLib.File.WebDTO]
}

extension FilesContext {
    struct Singular: Encodable {
        let sidebarLocation: SidebarLocation = .files
        var id: UUID
        var file: RipLib.File.WebDTO
    }
}
