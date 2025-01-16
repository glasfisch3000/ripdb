import Vapor
import Fluent
import RipLib

@Sendable
func collectionsList(request req: Request) async throws -> View {
    let collections = try await CollectionModel.query(on: req.db)
        .sort(\.$name)
        .all()
    
    let context = CollectionsContext(collections: collections.map { $0.toWebDTO() })
    return try await req.view.render("collections", context)
}

@Sendable
func collectionsGet(request req: Request) async throws -> View {
    guard let id = req.parameters.get("id", as: UUID.self) else {
        return try await req.view.render("invalidID", InvalidIDContext(type: "collection", sidebarLocation: .collections))
    }
    
    guard let collection = try await CollectionModel.find(id, on: req.db) else {
        return try await req.view.render("notFound", NotFoundContext(type: "collection", id: id, sidebarLocation: .collections))
    }
    
    try await collection.$projects.load(on: req.db)
    
    let context = CollectionsContext.Singular(id: id, collection: collection.toWebDTO())
    return try await req.view.render("collection", context)
}

struct CollectionsContext: Encodable {
    let sidebarLocation: SidebarLocation = .collections
    var collections: [CollectionModel.WebDTO]
}

extension CollectionsContext {
    struct Singular: Encodable {
        let sidebarLocation: SidebarLocation = .collections
        var id: UUID
        var collection: CollectionModel.WebDTO
    }
}
