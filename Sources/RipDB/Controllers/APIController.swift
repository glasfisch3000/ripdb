import Vapor
import Leaf

struct APIController: RouteCollection {
    struct InvalidIDContext: Codable {
        var type: String
    }
    
    struct NotFoundContext: Codable {
        var type: String
        var id: UUID
    }
    
    struct LocationContext: Codable {
        var id: UUID
        var location: LocationDTO.WithHexHash
    }
    
    struct FileContext: Codable {
        var id: UUID
        var file: FileDTO.WithHexHash
    }
    
    struct VideoContext: Codable {
        var id: UUID
        var video: VideoDTO.WithHexHash
    }
    
    struct ProjectContext: Codable {
        var id: UUID
        var project: ProjectDTO.WithHexHash
    }
    
    func boot(routes: any RoutesBuilder) throws {
        let locations = routes.grouped("locations")
        locations.get(":id", use: locationsGet(request:))
        
        let files = routes.grouped("files")
        files.get(":id", use: filesGet(request:))
        
        let videos = routes.grouped("videos")
        videos.get(":id", use: videosGet(request:))
        
        let projects = routes.grouped("projects")
        projects.get(":id", use: projectsGet(request:))
    }
    
    @Sendable
    func locationsGet(request req: Request) async throws -> View {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            return try await req.view.render("invalidID", InvalidIDContext(type: "location"))
        }
        
        guard let location = try await Location.find(id, on: req.db) else {
            return try await req.view.render("notFound", NotFoundContext(type: "location", id: id))
        }
        
        _ = try await location.$files.get(on: req.db).get().map { file in
            file.$video.get(on: req.db).flatMap { video in
                video.$project.load(on: req.db)
            }
        }
        .flatten(on: req.eventLoop)
        .get()
        
        let context = LocationContext(id: id, location: location.toDTO().toHexHash())
        return try await req.view.render("location", context)
    }
    
    @Sendable
    func filesGet(request req: Request) async throws -> View {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            return try await req.view.render("invalidID", InvalidIDContext(type: "file"))
        }
        
        guard let file = try await File.find(id, on: req.db) else {
            return try await req.view.render("notFound", NotFoundContext(type: "file", id: id))
        }
        
        try await file.$location.load(on: req.db)
        _ = try await file.$video.get(on: req.db).flatMap { video in
            video.$project.load(on: req.db)
        }
        .get()
        
        let context = FileContext(id: id, file: file.toDTO().toHexHash())
        return try await req.view.render("file", context)
    }
    
    @Sendable
    func videosGet(request req: Request) async throws -> View {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            return try await req.view.render("invalidID", InvalidIDContext(type: "video"))
        }
        
        guard let video = try await Video.find(id, on: req.db) else {
            return try await req.view.render("notFound", NotFoundContext(type: "video", id: id))
        }
        
        try await video.$project.load(on: req.db)
        _ = try await video.$files.get(on: req.db).get().map { file in
            file.$location.load(on: req.db)
        }
        .flatten(on: req.eventLoop)
        .get()
        
        let context = VideoContext(id: id, video: video.toDTO().toHexHash())
        return try await req.view.render("video", context)
    }
    
    @Sendable
    func projectsGet(request req: Request) async throws -> View {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            return try await req.view.render("invalidID", InvalidIDContext(type: "project"))
        }
        
        guard let project = try await Project.find(id, on: req.db) else {
            return try await req.view.render("notFound", NotFoundContext(type: "project", id: id))
        }
        
        try await project.$collection.load(on: req.db)
        try await project.$videos.load(on: req.db)
        
        let context = ProjectContext(id: id, project: project.toDTO().toHexHash())
        return try await req.view.render("project", context)
    }
}
