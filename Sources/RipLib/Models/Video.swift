import Fluent
import Foundation

public final class Video: Model, @unchecked Sendable {
    public static let schema = "videos"
    
    @ID(key: .id)
    public var id: UUID?

    @Field(key: "name")
    public var name: String
    
    @Enum(key: "type")
    public var type: VideoType
    
    @Parent(key: "project")
    public var project: Project
    
    @Children(for: \.$video)
    public var files: [File]

    public init() { }

    public init(id: UUID? = nil, name: String, type: VideoType, projectID: Project.IDValue?) {
        self.id = id
        self.name = name
        self.type = type
        if let projectID = projectID { self.$project.id = projectID }
    }
}
