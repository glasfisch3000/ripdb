import struct Foundation.UUID
import RipLib

extension APIContext {
    struct Videos: Encodable {
        let sidebarLocation: APIContext.SidebarLocation = .videos
        var videos: [Video.WebDTO]
    }
}

extension APIContext.Videos {
    struct Singular: Encodable {
        let sidebarLocation: APIContext.SidebarLocation = .videos
        var id: UUID
        var video: Video.WebDTO
    }
}
