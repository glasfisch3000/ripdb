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
    
    struct LocationsListContext: Codable {
        var locations: [LocationDTO.WithHexHash]
    }
    
    struct LocationsGetContext: Codable {
        var id: UUID
        var location: LocationDTO.WithHexHash
    }
    
    struct FilesListContext: Codable {
        var files: [FileDTO.WithHexHash]
    }
    
    struct FilesGetContext: Codable {
        var id: UUID
        var file: FileDTO.WithHexHash
    }
    
    struct VideosListContext: Codable {
        var videos: [VideoDTO.WithHexHash]
    }
    
    struct VideosGetContext: Codable {
        var id: UUID
        var video: VideoDTO.WithHexHash
    }
    
    struct ProjectsListContext: Codable {
        var projects: [ProjectDTO.WithHexHash]
    }
    
    struct ProjectsGetContext: Codable {
        var id: UUID
        var project: ProjectDTO.WithHexHash
    }
    
    struct CollectionsListContext: Codable {
        var collections: [CollectionDTO.WithHexHash]
    }
    
    struct CollectionsGetContext: Codable {
        var id: UUID
        var collection: CollectionDTO.WithHexHash
    }
    
    func boot(routes: any RoutesBuilder) throws {
        let locations = routes.grouped("locations")
        locations.get(use: locationsList(request:))
        locations.get(":id", use: locationsGet(request:))
        
        let files = routes.grouped("files")
        files.get(use: filesList(request:))
        files.get(":id", use: filesGet(request:))
        
        let videos = routes.grouped("videos")
        videos.get(use: videosList(request:))
        videos.get(":id", use: videosGet(request:))
        
        let projects = routes.grouped("projects")
        projects.get(use: projectsList(request:))
        projects.get(":id", use: projectsGet(request:))
        
        let collections = routes.grouped("collections")
        collections.get(use: collectionsList(request:))
        collections.get(":id", use: collectionsGet(request:))
    }
    
    @Sendable
    func locationsList(request req: Request) async throws -> View {
        let locations = try await Location.query(on: req.db)
            .sort(\.$name)
            .all()
        
        let context = LocationsListContext(locations: locations.map { $0.toDTO().toHexHash() })
        return try await req.view.render("locations", context)
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
        
        let context = LocationsGetContext(id: id, location: location.toDTO().toHexHash())
        return try await req.view.render("location", context)
    }
    
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
        
        let context = FilesListContext(files: files.map { $0.toDTO().toHexHash() })
        return try await req.view.render("files", context)
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
        
        let context = FilesGetContext(id: id, file: file.toDTO().toHexHash())
        return try await req.view.render("file", context)
    }
    
    @Sendable
    func videosList(request req: Request) async throws -> View {
        let videos = try await Video.query(on: req.db)
            .with(\.$project)
            .join(parent: \.$project)
            .sort(Project.self, \.$name)
            .sort(\.$type)
            .sort(\.$name)
            .all()
        
        let context = VideosListContext(videos: videos.map { $0.toDTO().toHexHash() })
        return try await req.view.render("videos", context)
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
        
        let context = VideosGetContext(id: id, video: video.toDTO().toHexHash())
        return try await req.view.render("video", context)
    }
    
    @Sendable
    func projectsList(request req: Request) async throws -> View {
        let projects = try await Project.query(on: req.db)
            .with(\.$collection)
            .join(parent: \.$collection)
            .sort(CollectionModel.self, \.$name)
            .sort(\.$releaseYear)
            .sort(\.$name)
            .sort(\.$type)
            .all()
        
        let context = ProjectsListContext(projects: projects.map { $0.toDTO().toHexHash() })
        return try await req.view.render("projects", context)
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
        
        let context = ProjectsGetContext(id: id, project: project.toDTO().toHexHash())
        return try await req.view.render("project", context)
    }
    
    @Sendable
    func collectionsList(request req: Request) async throws -> View {
        let collections = try await CollectionModel.query(on: req.db)
            .sort(\.$name)
            .all()
        
        let context = CollectionsListContext(collections: collections.map { $0.toDTO().toHexHash() })
        return try await req.view.render("collections", context)
    }
    
    @Sendable
    func collectionsGet(request req: Request) async throws -> View {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            return try await req.view.render("invalidID", InvalidIDContext(type: "collection"))
        }
        
        guard let collection = try await CollectionModel.find(id, on: req.db) else {
            return try await req.view.render("notFound", NotFoundContext(type: "collection", id: id))
        }
        
        try await collection.$projects.load(on: req.db)
        
        let context = CollectionsGetContext(id: id, collection: collection.toDTO().toHexHash())
        return try await req.view.render("collection", context)
    }
}
