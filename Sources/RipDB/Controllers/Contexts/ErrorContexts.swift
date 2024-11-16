import struct Foundation.UUID

extension APIContext {
    struct InvalidID: Codable {
        var type: String
        var sidebarLocation: APIContext.SidebarLocation
    }
    
    struct NotFound: Codable {
        var type: String
        var id: UUID
        var sidebarLocation: APIContext.SidebarLocation
    }
}
