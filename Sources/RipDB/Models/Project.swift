import Fluent
import Foundation

final class Project: Model, Sendable {
    static let schema = "projects"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Enum(key: "type")
    var type: ProjectType
    
    @Field(key: "release_year")
    var releaseYear: Int
    
    @OptionalParent(key: "collection")
    var collection: CollectionModel?
    
    @Children(for: \.$project)
    var videos: [Video]

    init() { }

    init(id: UUID? = nil, name: String, type: ProjectType, releaseYear: Int, collectionID: CollectionModel.IDValue?) {
        self.id = id
        self.name = name
        self.type = type
        self.releaseYear = releaseYear
        if let collectionID = collectionID { self.$collection.id = collectionID }
    }
    
    func toDTO() -> ProjectDTO {
        ProjectDTO(id: self.id,
                   name: self.name,
                   type: self.type,
                   releaseYear: self.releaseYear,
                   collection: self.$collection.value??.toDTO(),
                   videos: self.$videos.value?.map { $0.toDTO() })
    }
}
