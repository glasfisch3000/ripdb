import Vapor
import Fluent
import Leaf

struct APIController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.get(use: dashboardGet(request:))
        
        let locations = routes.grouped("locations")
        locations.get(use: locationsList(request:))
        locations.get(":id", use: locationsGet(request:))
        locations.get(":id", "files", use: locationsGetFiles(request:))
        
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
    func dashboardGet(request req: Request) async throws -> View {
        let locationsLimit = 10
        let itemsLimit = 10
        
        let locations = try await Location.query(on: req.db)
            .sort(\.$name)
            .limit(locationsLimit)
            .all()
        
        let collections = try await CollectionModel.query(on: req.db)
            .limit(itemsLimit)
            .all()
        
        let projects = try await Project.query(on: req.db)
            .filter(\.$collection.$id == nil)
            .limit(itemsLimit)
            .all()
        
        let items = (collections.map(APIContext.Item.collection(_:)) + projects.map(APIContext.Item.project(_:)))
            .sorted(using: KeyPathComparator(\.name))
            .prefix(itemsLimit)
        
        let context = APIContext(locations: locations.map { $0.toDTO().toWebView() },
                                 items: Array(items))
        return try await req.view.render("dashboard", context)
    }
    
    @Sendable
    func locationsList(request req: Request) async throws -> View {
        let locations = try await Location.query(on: req.db)
            .sort(\.$name)
            .all()
        
        let context = APIContext.Locations(locations: locations.map { $0.toDTO().toWebView() })
        return try await req.view.render("locations", context)
    }
    
    @Sendable
    func locationsGet(request req: Request) async throws -> View {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            return try await req.view.render("invalidID", APIContext.InvalidID(type: "location", sidebarLocation: .locations))
        }
        
        guard let location = try await Location.find(id, on: req.db) else {
            return try await req.view.render("notFound", APIContext.NotFound(type: "location", id: id, sidebarLocation: .locations))
        }
        
        let query = try await File.query(on: req.db)
            .with(\.$video) {
                $0.with(\.$project)
            }
            .filter(File.self, \.$location.$id == id)
            .join(parent: \.$video)
            .join(from: Video.self, parent: \.$project)
            .sort(Project.self, \.$name)
            .sort(Video.self, \.$type)
            .sort(Video.self, \.$name)
            .sort(\.$resolution)
            .sort(\.$is3D)
            .sort(\.$size)
            .all()
        
        var projects: [UUID: APIContext.Locations.Singular.Project] = [:]
        
        for file in query {
            let video = file.video
            let videoID = try video.requireID()
            
            let project = video.project
            let projectID = try project.requireID()
            
            // ensure project exists
            var p = try projects[projectID] ?? .init(from: project)
            defer { projects[projectID] = p }
            
            // ensure project contains video
            func newVIndex() throws -> Int {
                p.videos.append(try .init(from: video))
                return p.videos.endIndex-1
            }
            let vIndex = try p.videos.firstIndex(where: { $0.id == videoID }) ?? newVIndex()
            var v = p.videos[vIndex]
            defer { p.videos[vIndex] = v }
            
            // ensure video contains file
            v.files.append(try .init(from: file))
        }
        
        let sorted = projects.values.sorted(using: KeyPathComparator(\.name))
        
        let context = APIContext.Locations.Singular(id: id,
                                                    location: location.toDTO().toWebView(),
                                                    projects: sorted)
        return try await req.view.render("location", context)
    }
    
    @Sendable
    func locationsGetFiles(request req: Request) async throws -> View {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            return try await req.view.render("invalidID", APIContext.InvalidID(type: "location", sidebarLocation: .locations))
        }
        
        guard let location = try await Location.find(id, on: req.db) else {
            return try await req.view.render("notFound", APIContext.NotFound(type: "location", id: id, sidebarLocation: .locations))
        }
        
        let files = try await File.query(on: req.db)
            .filter(\.$location.$id == id)
            .with(\.$video) {
                $0.with(\.$project)
            }
            .sort(\.$size, .descending)
            .all()
        
        let context = APIContext.Locations.Singular.Files(id: id,
                                                          location: location.toDTO().toWebView(),
                                                          files: files.map { $0.toDTO().toWebView() })
        return try await req.view.render("location-files", context)
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
        
        let context = APIContext.Files(files: files.map { $0.toDTO().toWebView() })
        return try await req.view.render("files", context)
    }
    
    @Sendable
    func filesGet(request req: Request) async throws -> View {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            return try await req.view.render("invalidID", APIContext.InvalidID(type: "file", sidebarLocation: .files))
        }
        
        guard let file = try await File.find(id, on: req.db) else {
            return try await req.view.render("notFound", APIContext.NotFound(type: "file", id: id, sidebarLocation: .files))
        }
        
        try await file.$location.load(on: req.db)
        _ = try await file.$video.get(on: req.db).flatMap { video in
            video.$project.load(on: req.db)
        }
        .get()
        
        let context = APIContext.Files.Singular(id: id, file: file.toDTO().toWebView())
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
        
        let context = APIContext.Videos(videos: videos.map { $0.toDTO().toWebView() })
        return try await req.view.render("videos", context)
    }
    
    @Sendable
    func videosGet(request req: Request) async throws -> View {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            return try await req.view.render("invalidID", APIContext.InvalidID(type: "video", sidebarLocation: .videos))
        }
        
        guard let video = try await Video.find(id, on: req.db) else {
            return try await req.view.render("notFound", APIContext.NotFound(type: "video", id: id, sidebarLocation: .videos))
        }
        
        try await video.$project.load(on: req.db)
        _ = try await video.$files.get(on: req.db).get().map { file in
            file.$location.load(on: req.db)
        }
        .flatten(on: req.eventLoop)
        .get()
        
        let context = APIContext.Videos.Singular(id: id, video: video.toDTO().toWebView())
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
        
        let context = APIContext.Projects(projects: projects.map { $0.toDTO().toWebView() })
        return try await req.view.render("projects", context)
    }
    
    @Sendable
    func projectsGet(request req: Request) async throws -> View {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            return try await req.view.render("invalidID", APIContext.InvalidID(type: "project", sidebarLocation: .projects))
        }
        
        guard let project = try await Project.find(id, on: req.db) else {
            return try await req.view.render("notFound", APIContext.NotFound(type: "project", id: id, sidebarLocation: .projects))
        }
        
        try await project.$collection.load(on: req.db)
        try await project.$videos.load(on: req.db)
        
        let context = APIContext.Projects.Singular(id: id, project: project.toDTO().toWebView())
        return try await req.view.render("project", context)
    }
    
    @Sendable
    func collectionsList(request req: Request) async throws -> View {
        let collections = try await CollectionModel.query(on: req.db)
            .sort(\.$name)
            .all()
        
        let context = APIContext.Collections(collections: collections.map { $0.toDTO().toWebView() })
        return try await req.view.render("collections", context)
    }
    
    @Sendable
    func collectionsGet(request req: Request) async throws -> View {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            return try await req.view.render("invalidID", APIContext.InvalidID(type: "collection", sidebarLocation: .collections))
        }
        
        guard let collection = try await CollectionModel.find(id, on: req.db) else {
            return try await req.view.render("notFound", APIContext.NotFound(type: "collection", id: id, sidebarLocation: .collections))
        }
        
        try await collection.$projects.load(on: req.db)
        
        let context = APIContext.Collections.Singular(id: id, collection: collection.toDTO().toWebView())
        return try await req.view.render("collection", context)
    }
}

/*
 SELECT "files"."id", "files"."resolution", "files"."is_3d", "files"."size", "files"."content_hash_sha256", "files"."location", "files"."video" FROM "files" WHERE "files"."location" = $1
 SELECT "videos"."id", "videos"."name", "videos"."type", "videos"."project" FROM "videos" WHERE "videos"."id" = $1 LIMIT 1
 SELECT "projects"."id", "projects"."name", "projects"."type", "projects"."release_year", "projects"."collection" FROM "projects" WHERE "projects"."id" = $1 LIMIT 1
 */
