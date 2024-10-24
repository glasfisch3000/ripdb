import Fluent
import Vapor

struct LocationDTO: Content {
    var id: UUID?
    var name: String
    var capacity: Double?
    
    var files: [FileDTO]?
    
    func toModel() -> Location {
        Location(id: self.id, name: self.name, capacity: self.capacity)
    }
}
