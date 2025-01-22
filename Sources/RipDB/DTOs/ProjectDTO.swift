import struct Foundation.UUID
import protocol Vapor.Content

extension Project {
    public struct DTO: Sendable, Content {
        public var id: UUID?
        public var name: String
        public var type: ProjectType
        public var releaseYear: Int
        
        public var collectionID: UUID?
        public var videoIDs: [UUID]?
    }
    
    public func toDTO() -> DTO {
        DTO(id: self.id,
            name: self.name,
            type: self.type,
            releaseYear: self.releaseYear,
            collectionID: self.$collection.$id.value?.wrapped,
            videoIDs: self.$videos.value?.compactMap(\.$id.value))
    }
}
