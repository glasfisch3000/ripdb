import Fluent
import Foundation

public final class CollectionModel: Model, Sendable {
    public static let schema = "collections"
    
    @ID(key: .id)
    public var id: UUID?

    @Field(key: "name")
    public var name: String
    
    @Children(for: \.$collection)
    public var projects: [Project]

    public init() { }

    public init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
}
