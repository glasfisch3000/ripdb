import Fluent
import Vapor

struct VideoDTO: Sendable, Content {
    var id: UUID?
    var name: String
    var type: VideoType
    
    var project: ProjectDTO?
    var files: [FileDTO]?
    
    func toModel() -> Video {
        Video(id: self.id,
                name: self.name,
                type: self.type,
                projectID: self.project?.id)
    }
    
    func toHexHash() -> Self.WithHexHash {
        WithHexHash(id: self.id,
                    name: self.name,
                    type: self.type,
                    project: self.project?.toHexHash(),
                    files: self.files?.map { $0.toHexHash() })
    }
}

extension VideoDTO {
    struct WithHexHash: Sendable, Content {
        var id: UUID?
        var name: String
        var type: VideoType
        
        var project: ProjectDTO.WithHexHash?
        var files: [FileDTO.WithHexHash]?
    }
}
