import struct Foundation.UUID
import RipLib

extension APIContext {
    struct Files: Encodable {
        let sidebarLocation: APIContext.SidebarLocation = .files
        var files: [File.WebDTO]
    }
}

extension APIContext.Files {
    struct Singular: Encodable {
        let sidebarLocation: APIContext.SidebarLocation = .files
        var id: UUID
        var file: File.WebDTO
    }
}
