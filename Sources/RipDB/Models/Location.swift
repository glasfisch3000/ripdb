import Fluent
import struct Foundation.UUID

final class Location: Model, @unchecked Sendable {
    static let schema = "locations"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    init() { }

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
    
    func toDTO() -> LocationDTO {
        LocationDTO(id: self.id, name: self.name)
    }
}
