import Fluent
import struct Foundation.UUID

final class CollectionModel: Model, Sendable {
    static let schema = "collections"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Children(for: \.$collection)
    var projects: [Project]

    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
    
    func toDTO() -> CollectionDTO {
        CollectionDTO(id: self.id, name: self.name)
    }
}
