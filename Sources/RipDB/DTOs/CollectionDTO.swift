import Fluent
import Vapor

struct CollectionDTO: Content {
    var id: UUID?
    var name: String
    
    var projects: [ProjectDTO]?
    
    func toModel() -> CollectionModel {
        CollectionModel(id: self.id, name: self.name)
    }
}
