import struct Foundation.UUID
import protocol Vapor.Content

extension Video {
    public struct DTO: Sendable, Content {
        public var id: UUID?
        public var name: String
        public var type: VideoType
        
        public var projectID: UUID?
        public var fileIDs: [UUID]?
    }
    
    public func toDTO() -> DTO {
        DTO(id: self.id,
            name: self.name,
            type: self.type,
            projectID: self.$project.$id.value,
            fileIDs: self.$files.value?.compactMap(\.$id.value))
    }
}
