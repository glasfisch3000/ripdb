import Fluent
import Vapor

struct CollectionDTO: Sendable, Content {
    var id: UUID?
    var name: String
    
    var projects: [ProjectDTO]?
    
    func toModel() -> CollectionModel {
        CollectionModel(id: self.id, name: self.name)
    }
    
    func toHexHash() -> Self.WithHexHash {
        WithHexHash(id: self.id,
                    name: self.name,
                    projects: self.projects?.map { $0.toHexHash() })
    }
}

extension CollectionDTO {
    struct WithHexHash: Sendable, Content {
        var id: UUID?
        var name: String
        
        var projects: [ProjectDTO.WithHexHash]?
    }
}
