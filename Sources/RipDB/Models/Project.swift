import Fluent
import struct Foundation.Date
import struct Foundation.UUID

final class Project: Model, Sendable {
    static let schema = "projects"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Enum(key: "type")
    var type: ProjectType
    
    @Field(key: "release_date")
    var releaseDate: Date
    
    @OptionalParent(key: "collection")
    var collection: CollectionModel?
    
    @Children(for: \.$project)
    var videos: [Video]

    init() { }

    init(id: UUID? = nil, name: String, type: ProjectType, releaseDate: Date, collectionID: CollectionModel.IDValue?) {
        self.id = id
        self.name = name
        self.type = type
        self.releaseDate = releaseDate
        if let collectionID = collectionID { self.$collection.id = collectionID }
    }
    
    func toDTO() -> ProjectDTO {
        ProjectDTO(id: self.id,
                   name: self.name,
                   type: self.type,
                   releaseDate: self.releaseDate,
                   collection: self.collection?.toDTO())
    }
}
