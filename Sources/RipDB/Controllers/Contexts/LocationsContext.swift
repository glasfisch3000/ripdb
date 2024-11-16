import struct Foundation.UUID

extension APIContext {
    struct Locations: Encodable {
        let sidebarLocation: APIContext.SidebarLocation = .locations
        var locations: [LocationDTO.WebView]
    }
}

extension APIContext.Locations {
    struct Singular: Encodable {
        struct Project: Encodable {
            var id: UUID
            var name: String
            var type: ProjectType
            var releaseYear: Int
            var videos: [Singular.Video]
            
            init(id: UUID, name: String, type: ProjectType, releaseYear: Int, videos: [Singular.Video]) {
                self.id = id
                self.name = name
                self.type = type
                self.releaseYear = releaseYear
                self.videos = videos
            }
            
            init(from project: ripdb.Project) throws {
                self.id = try project.requireID()
                self.name = project.name
                self.type = project.type
                self.releaseYear = project.releaseYear
                self.videos = try project.$videos.value?.map(Singular.Video.init(from:)) ?? []
            }
        }
        
        struct Video: Encodable {
            var id: UUID
            var name: String
            var type: VideoType
            var files: [Singular.File]
            
            init(id: UUID, name: String, type: VideoType, files: [Singular.File]) {
                self.id = id
                self.name = name
                self.type = type
                self.files = files
            }
            
            init(from video: ripdb.Video) throws {
                self.id = try video.requireID()
                self.name = video.name
                self.type = video.type
                self.files = try video.$files.value?.map(Singular.File.init(from:)) ?? []
            }
        }
        
        struct File: Encodable {
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
            
            init(from file: ripdb.File) throws {
                self.id = try file.requireID()
                self.resolution = file.resolution
                self.is3D = file.is3D
                self.size = file.size
                self.contentHashSHA256 = file.contentHashSHA256.hexEncodedString()
            }
        }
        
        let sidebarLocation: APIContext.SidebarLocation = .locations
        var id: UUID
        var location: LocationDTO.WebView
        var projects: [Singular.Project]
    }
}

extension APIContext.Locations.Singular {
    struct Files: Encodable {
        let sidebarLocation: APIContext.SidebarLocation = .locations
        var id: UUID
        var location: LocationDTO.WebView
        var files: [FileDTO.WebView]
    }
}
