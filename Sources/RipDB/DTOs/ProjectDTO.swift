import Fluent
import Vapor

struct ProjectDTO: Content {
    var id: UUID?
    var name: String
    var type: ProjectType
    var releaseYear: Int
    
    var collection: CollectionDTO?
    var videos: [VideoDTO]?
    
    func toModel() -> Project {
        Project(id: self.id,
                name: self.name,
                type: self.type,
                releaseYear: self.releaseYear,
                collectionID: self.collection?.id)
    }
    
    func toHexHash() -> Self.WithHexHash {
        WithHexHash(id: self.id,
                    name: self.name,
                    type: self.type,
                    releaseYear: self.releaseYear,
                    collection: self.collection,
                    videos: self.videos?.map { $0.toHexHash() })
    }
}

extension ProjectDTO {
    struct WithHexHash: Content {
        var id: UUID?
        var name: String
        var type: ProjectType
        var releaseYear: Int
        
        var collection: CollectionDTO?
        var videos: [VideoDTO.WithHexHash]?
    }
}
