import Fluent
import struct Foundation.UUID

final class Location: Model, Sendable {
    static let schema = "locations"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Field(key: "capacity")
    var capacity: UInt64?

    init() { }

    init(id: UUID? = nil, name: String, capacity: UInt64?) {
        self.id = id
        self.name = name
        self.capacity = capacity
    }
    
    func toDTO() -> LocationDTO {
        LocationDTO(id: self.id, name: self.name, capacity: self.capacity)
    }
}
