import Fluent
import Vapor

struct LocationDTO: Content {
    var id: UUID?
    var name: String
    var capacity: UInt64?
    
    func toModel() -> Location {
        Location(id: self.id, name: self.name, capacity: self.capacity)
    }
}
