import Vapor
import Fluent
import RipLib

@Sendable
func dashboardGet(request req: Request) async throws -> View {
    let locationsLimit = 10
    let itemsLimit = 10
    
    let locations = try await Location.query(on: req.db)
        .sort(\.$name)
        .limit(locationsLimit)
        .all()
    
    let collections = try await CollectionModel.query(on: req.db)
        .limit(itemsLimit)
        .all()
    
    let projects = try await Project.query(on: req.db)
        .filter(\.$collection.$id == nil)
        .limit(itemsLimit)
        .all()
    
    let items = (collections.map(DashboardContext.Item.collection(_:)) + projects.map(DashboardContext.Item.project(_:)))
        .sorted(using: KeyPathComparator(\.name))
        .prefix(itemsLimit)
    
    let context = DashboardContext(locations: locations.map { $0.toWebDTO() },
                                   items: Array(items))
    return try await req.view.render("dashboard", context)
}

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
