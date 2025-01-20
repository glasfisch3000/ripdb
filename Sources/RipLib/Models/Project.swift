import Fluent
import Foundation

public final class Project: Model, @unchecked Sendable {
    public static let schema = "projects"
    
    @ID(key: .id)
    public var id: UUID?

    @Field(key: "name")
    public var name: String
    
    @Enum(key: "type")
    public var type: ProjectType
    
    @Field(key: "release_year")
    public var releaseYear: Int
    
    @OptionalParent(key: "collection")
    public var collection: CollectionModel?
    
    @Children(for: \.$project)
    public var videos: [Video]

    public init() { }

    public init(id: UUID? = nil, name: String, type: ProjectType, releaseYear: Int, collectionID: CollectionModel.IDValue?) {
        self.id = id
        self.name = name
        self.type = type
        self.releaseYear = releaseYear
        if let collectionID = collectionID { self.$collection.id = collectionID }
    }
}
