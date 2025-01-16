import RipLib

struct DashboardContext: Codable {
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
            case .collection(let collection): try container.encode(collection.toWebDTO(), forKey: .collection)
            case .project(let project): try container.encode(project.toWebDTO(), forKey: .project)
            }
        }
    }
    
    var locations: [Location.WebDTO]
    var items: [Item]
}
