import struct Foundation.UUID
import protocol Vapor.Content

extension CollectionModel {
    public struct DTO: Sendable, Content {
        public var id: UUID?
        public var name: String
        
        public var projectIDs: [UUID]?
    }
    
    public func toDTO() -> DTO {
        DTO(id: self.id,
            name: self.name,
            projectIDs: self.$projects.value?.compactMap(\.$id.value))
    }
}
