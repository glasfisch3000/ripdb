import struct Foundation.UUID
import RipLib

extension APIContext {
    struct Collections: Encodable {
        let sidebarLocation: APIContext.SidebarLocation = .collections
        var collections: [CollectionModel.WebDTO]
    }
}

extension APIContext.Collections {
    struct Singular: Encodable {
        let sidebarLocation: APIContext.SidebarLocation = .collections
        var id: UUID
        var collection: CollectionModel.WebDTO
    }
}
