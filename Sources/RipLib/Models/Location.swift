import Fluent
import Foundation

public final class Location: Model, @unchecked Sendable {
    public static let schema = "locations"
    
    @ID(key: .id)
    public var id: UUID?

    @Field(key: "name")
    public var name: String
    
    @Field(key: "capacity")
    public var capacity: Int?
    
    @Children(for: \.$location)
    public var files: [File]

    public init() { }

    public init(id: UUID? = nil, name: String, capacity: Int?) {
        self.id = id
        self.name = name
        self.capacity = capacity
    }
}
