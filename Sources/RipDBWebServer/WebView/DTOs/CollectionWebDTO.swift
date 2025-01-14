import RipLib
import struct Foundation.UUID
import protocol Vapor.Content

extension CollectionModel {
    struct WebDTO: Sendable, Content {
        var id: UUID?
        var name: String
        
        var projects: [Project.WebDTO]?
    }
    
    func toWebDTO() -> WebDTO {
        WebDTO(id: self.id,
               name: self.name,
               projects: self.$projects.value?.map { $0.toWebDTO() })
    }
}
