import Fluent
import Foundation

final class Video: Model, Sendable {
    static let schema = "videos"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Enum(key: "type")
    var type: VideoType
    
    @Parent(key: "project")
    var project: Project
    
    @Children(for: \.$video)
    var files: [File]

    init() { }

    init(id: UUID? = nil, name: String, type: VideoType, projectID: Project.IDValue?) {
        self.id = id
        self.name = name
        self.type = type
        if let projectID = projectID { self.$project.id = projectID }
    }
    
    func toDTO() -> VideoDTO {
        VideoDTO(id: self.id,
                 name: self.name,
                 type: self.type,
                 project: self.$project.value?.toDTO(),
                 files: self.$files.value?.map { $0.toDTO() })
    }
}
