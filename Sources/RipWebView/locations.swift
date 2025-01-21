import Vapor
import Fluent
import RipDB

@Sendable
func locationsList(request req: Request) async throws -> View {
    let locations = try await Location.query(on: req.db)
        .sort(\.$name)
        .all()
    
    let context = LocationsContext(locations: locations.map { $0.toWebDTO() })
    return try await req.view.render("locations", context)
}

@Sendable
func locationsGet(request req: Request) async throws -> View {
    guard let id = req.parameters.get("id", as: UUID.self) else {
        return try await req.view.render("invalidID", InvalidIDContext(type: "location", sidebarLocation: .locations))
    }
    
    guard let location = try await Location.find(id, on: req.db) else {
        return try await req.view.render("notFound", NotFoundContext(type: "location", id: id, sidebarLocation: .locations))
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
    
    var projects: [UUID: LocationsContext.Singular.ProjectItem] = [:]
    
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
    
    let context = LocationsContext.Singular(id: id,
                                                location: location.toWebDTO(),
                                                projects: sorted)
    return try await req.view.render("location", context)
}

@Sendable
func locationsGetFiles(request req: Request) async throws -> View {
    guard let id = req.parameters.get("id", as: UUID.self) else {
        return try await req.view.render("invalidID", InvalidIDContext(type: "location", sidebarLocation: .locations))
    }
    
    guard let location = try await Location.find(id, on: req.db) else {
        return try await req.view.render("notFound", NotFoundContext(type: "location", id: id, sidebarLocation: .locations))
    }
    
    let files = try await File.query(on: req.db)
        .filter(\.$location.$id == id)
        .with(\.$video) {
            $0.with(\.$project)
        }
        .sort(\.$size, .descending)
        .all()
    
    let context = LocationsContext.Singular.Files(id: id,
                                                      location: location.toWebDTO(),
                                                      files: files.map { $0.toWebDTO() })
    return try await req.view.render("location-files", context)
}

struct LocationsContext: Encodable {
    let sidebarLocation: SidebarLocation = .locations
    var locations: [Location.WebDTO]
}

extension LocationsContext {
    struct Singular: Encodable {
        struct ProjectItem: Encodable {
            var id: UUID
            var name: String
            var type: ProjectType
            var releaseYear: Int
            var videos: [VideoItem]
            
            init(id: UUID, name: String, type: ProjectType, releaseYear: Int, videos: [VideoItem]) {
                self.id = id
                self.name = name
                self.type = type
                self.releaseYear = releaseYear
                self.videos = videos
            }
            
            init(from project: Project) throws {
                self.id = try project.requireID()
                self.name = project.name
                self.type = project.type
                self.releaseYear = project.releaseYear
                self.videos = try project.$videos.value?.map(VideoItem.init(from:)) ?? []
            }
        }
        
        struct VideoItem: Encodable {
            var id: UUID
            var name: String
            var type: VideoType
            var files: [FileItem]
            
            init(id: UUID, name: String, type: VideoType, files: [FileItem]) {
                self.id = id
                self.name = name
                self.type = type
                self.files = files
            }
            
            init(from video: Video) throws {
                self.id = try video.requireID()
                self.name = video.name
                self.type = video.type
                self.files = try video.$files.value?.map(FileItem.init(from:)) ?? []
            }
        }
        
        struct FileItem: Encodable {
            var id: UUID
            var resolution: FileResolution
            var is3D: Bool
            var size: Int
            var contentHashSHA256: String
            
            init(id: UUID, resolution: FileResolution, is3D: Bool, size: Int, contentHashSHA256: String) {
                self.id = id
                self.resolution = resolution
                self.is3D = is3D
                self.size = size
                self.contentHashSHA256 = contentHashSHA256
            }
            
            init(from file: RipDB.File) throws {
                self.id = try file.requireID()
                self.resolution = file.resolution
                self.is3D = file.is3D
                self.size = file.size
                self.contentHashSHA256 = file.contentHashSHA256.hexEncodedString()
            }
        }
        
        let sidebarLocation: SidebarLocation = .locations
        var id: UUID
        var location: Location.WebDTO
        var projects: [ProjectItem]
    }
}

extension LocationsContext.Singular {
    struct Files: Encodable {
        let sidebarLocation: SidebarLocation = .locations
        var id: UUID
        var location: Location.WebDTO
        var files: [RipDB.File.WebDTO]
    }
}
