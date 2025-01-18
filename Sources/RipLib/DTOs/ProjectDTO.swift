import struct Foundation.UUID
import protocol Vapor.Content

extension Project {
    public struct DTO: Sendable, Content {
        public var id: UUID?
        public var name: String
        public var type: ProjectType
        public var releaseYear: Int
        
        public var collection: CollectionModel.DTO?
        public var videos: [Video.DTO]?
    }
    
    public func toDTO() -> DTO {
        DTO(id: self.id,
            name: self.name,
            type: self.type,
            releaseYear: self.releaseYear,
            collection: self.$collection.value??.toDTO(),
            videos: self.$videos.value?.map { $0.toDTO() })
    }
}
