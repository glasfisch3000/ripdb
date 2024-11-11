import Fluent
import Vapor

struct CollectionDTO: Sendable, Content {
    var id: UUID?
    var name: String
    
    var projects: [ProjectDTO]?
    
    func toModel() -> CollectionModel {
        CollectionModel(id: self.id, name: self.name)
    }
    
    func toWebView() -> Self.WebView {
        WebView(id: self.id,
                name: self.name,
                projects: self.projects?.map { $0.toWebView() })
    }
}

extension CollectionDTO {
    struct WebView: Sendable, Content {
        var id: UUID?
        var name: String
        
        var projects: [ProjectDTO.WebView]?
    }
}
