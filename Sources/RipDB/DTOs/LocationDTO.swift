import Fluent
import Vapor

struct LocationDTO: Sendable, Content {
    var id: UUID?
    var name: String
    var capacity: Int?
    
    var files: [FileDTO]?
    
    func toModel() -> Location {
        Location(id: self.id, name: self.name, capacity: self.capacity)
    }
    
    func toWebView() -> Self.WebView {
        WebView(id: self.id,
                name: self.name,
                capacity: self.capacity,
                files: self.files?.map { $0.toWebView() })
    }
}

extension LocationDTO {
    struct WebView: Sendable, Content {
        var id: UUID?
        var name: String
        var capacity: Int?
        
        var files: [FileDTO.WebView]?
    }
}
