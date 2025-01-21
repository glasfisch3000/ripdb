import RipDB
import struct Foundation.UUID
import protocol Vapor.Content

extension Video {
    struct WebDTO: Sendable, Content {
        var id: UUID?
        var name: String
        var type: VideoType
        
        var project: Project.WebDTO?
        var files: [File.WebDTO]?
    }
    
    func toWebDTO() -> WebDTO {
        WebDTO(id: self.id,
               name: self.name,
               type: self.type,
               project: self.$project.value?.toWebDTO(),
               files: self.$files.value?.map { $0.toWebDTO() })
    }
}
