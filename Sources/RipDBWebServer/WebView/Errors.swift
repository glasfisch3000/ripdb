import struct Foundation.UUID

struct InvalidIDContext: Codable {
    var type: String
    var sidebarLocation: SidebarLocation
}

struct NotFoundContext: Codable {
    var type: String
    var id: UUID
    var sidebarLocation: SidebarLocation
}
