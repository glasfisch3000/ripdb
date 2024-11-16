import struct Foundation.UUID

extension APIContext {
    struct Collections: Encodable {
        let sidebarLocation: APIContext.SidebarLocation = .collections
        var collections: [CollectionDTO.WebView]
    }
}

extension APIContext.Collections {
    struct Singular: Encodable {
        let sidebarLocation: APIContext.SidebarLocation = .collections
        var id: UUID
        var collection: CollectionDTO.WebView
    }
}
