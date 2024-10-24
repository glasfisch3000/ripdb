import Fluent
import Foundation

final class Location: Model, Sendable {
    static let schema = "locations"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Field(key: "capacity")
    var capacity: Double?
    
    @Children(for: \.$location)
    var files: [File]

    init() { }

    init(id: UUID? = nil, name: String, capacity: Double?) {
        self.id = id
        self.name = name
        self.capacity = capacity
    }
    
    func toDTO() -> LocationDTO {
        LocationDTO(id: self.id,
                    name: self.name,
                    capacity: self.capacity,
                    files: self.$files.value?.map { $0.toDTO() })
    }
}
