import struct Foundation.UUID
import RipLib

extension Project {
    struct DTO: Sendable, Encodable {
        var id: UUID?
        var name: String
        var type: ProjectType
        var releaseYear: Int
        
        var collection: CollectionModel.DTO?
        var videos: [Video.DTO]?
    }
    
    func toDTO() -> DTO {
        DTO(id: self.id,
            name: self.name,
            type: self.type,
            releaseYear: self.releaseYear,
            collection: self.$collection.value??.toDTO(),
            videos: self.$videos.value?.map { $0.toDTO() })
    }
}
