struct APIContext: Codable {
    enum Item: Codable {
        case collection(CollectionModel)
        case project(Project)
        
        var name: String {
            switch self {
            case .collection(let collection): collection.name
            case .project(let project): project.name
            }
        }
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .collection(let collection): try container.encode(collection, forKey: .collection)
            case .project(let project): try container.encode(project, forKey: .project)
            }
        }
    }
    
    enum SidebarLocation: String, Codable {
        case collections
        case projects
        case videos
        case files
        case locations
    }
    
    var locations: [LocationDTO.WebView]
    var items: [Item]
}
