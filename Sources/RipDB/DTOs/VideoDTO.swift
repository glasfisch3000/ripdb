import Fluent
import Vapor

struct VideoDTO: Content {
    var id: UUID?
    var name: String
    var type: VideoType
    var project: ProjectDTO?
    
    func toModel() -> Video {
        Video(id: self.id,
                name: self.name,
                type: self.type,
                projectID: self.project?.id)
    }
}
