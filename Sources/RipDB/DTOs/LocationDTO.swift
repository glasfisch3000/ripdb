import struct Foundation.UUID
import protocol Vapor.Content

extension Location {
    public struct DTO: Sendable, Content {
        public var id: UUID?
        public var name: String
        public var capacity: Int?
        
        public var fileIDs: [UUID]?
    }
    
    public func toDTO() -> DTO {
        DTO(id: self.id,
            name: self.name,
            capacity: self.capacity,
            fileIDs: self.$files.value?.compactMap(\.$id.value))
    }
}
