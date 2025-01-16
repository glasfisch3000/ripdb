import struct Foundation.UUID
import RipLib

struct FilesContext: Encodable {
    let sidebarLocation: SidebarLocation = .files
    var files: [File.WebDTO]
}

extension FilesContext {
    struct Singular: Encodable {
        let sidebarLocation: SidebarLocation = .files
        var id: UUID
        var file: File.WebDTO
    }
}
