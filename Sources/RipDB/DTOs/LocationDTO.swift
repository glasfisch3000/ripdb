import Fluent
import Vapor

struct LocationDTO: Content {
    var id: UUID?
    var name: String
    
    func toModel() -> Location {
        Location(id: self.id, name: self.name)
    }
}
