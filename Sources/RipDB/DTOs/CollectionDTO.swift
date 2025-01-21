import struct Foundation.UUID
import protocol Vapor.Content

extension CollectionModel {
    public struct DTO: Sendable, Content {
        public var id: UUID?
        public var name: String
        
        public var projects: [Project.DTO]?
    }
    
    public func toDTO() -> DTO {
        DTO(id: self.id,
            name: self.name,
            projects: self.$projects.value?.map { $0.toDTO() })
    }
}
