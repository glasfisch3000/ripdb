import struct Foundation.UUID

extension APIContext {
    struct Files: Encodable {
        let sidebarLocation: APIContext.SidebarLocation = .files
        var files: [FileDTO.WebView]
    }
}

extension APIContext.Files {
    struct Singular: Encodable {
        let sidebarLocation: APIContext.SidebarLocation = .files
        var id: UUID
        var file: FileDTO.WebView
    }
}
