import Fluent
import Vapor

struct LocationDTO: Sendable, Content {
    var id: UUID?
    var name: String
    var capacity: Int?
    
    var files: [FileDTO]?
    
    func toModel() -> Location {
        Location(id: self.id, name: self.name, capacity: self.capacity)
    }
    
    func toHexHash() -> Self.WithHexHash {
        WithHexHash(id: self.id,
                    name: self.name,
                    capacity: self.capacity,
                    files: self.files?.map { $0.toHexHash() })
    }
}

extension LocationDTO {
    struct WithHexHash: Sendable, Content {
        var id: UUID?
        var name: String
        var capacity: Int?
        
        var files: [FileDTO.WithHexHash]?
    }
}
