import Fluent
import Vapor

struct ProjectDTO: Content {
    var id: UUID?
    var name: String
    var type: ProjectType
    var releaseDate: Date
    var collection: CollectionDTO?
    
    func toModel() -> Project {
        Project(id: self.id,
                name: self.name,
                type: self.type,
                releaseDate: self.releaseDate,
                collectionID: self.collection?.id)
    }
}
