import RipDB
import struct Foundation.UUID
import protocol Vapor.Content

extension Location {
    struct WebDTO: Sendable, Content {
        var id: UUID?
        var name: String
        var capacity: Int?
        
        var files: [File.WebDTO]?
    }
    
    func toWebDTO() -> WebDTO {
        WebDTO(id: self.id,
               name: self.name,
               capacity: self.capacity,
               files: self.$files.value?.map { $0.toWebDTO() })
    }
}
