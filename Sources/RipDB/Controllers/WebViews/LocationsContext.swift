import struct Foundation.UUID

extension APIContext {
    struct Locations: Encodable {
        let sidebarLocation: APIContext.SidebarLocation = .locations
        var locations: [LocationDTO.WebView]
    }
}

extension APIContext.Locations {
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
            
            init(from file: File) throws {
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
        var projects: [ProjectItem]
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
