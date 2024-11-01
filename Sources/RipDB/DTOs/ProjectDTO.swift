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
}
