import Fluent
import Vapor

struct VideoDTO: Sendable, Content {
    var id: UUID?
    var name: String
    var type: VideoType
    
    var project: ProjectDTO?
    var files: [FileDTO]?
    
    func toModel() -> Video {
        Video(id: self.id,
                name: self.name,
                type: self.type,
                projectID: self.project?.id)
    }
    
    func toWebView() -> Self.WebView {
        WebView(id: self.id,
                name: self.name,
                type: self.type,
                project: self.project?.toWebView(),
                files: self.files?.map { $0.toWebView() })
    }
}

extension VideoDTO {
    struct WebView: Sendable, Content {
        var id: UUID?
        var name: String
        var type: VideoType
        
        var project: ProjectDTO.WebView?
        var files: [FileDTO.WebView]?
    }
}
