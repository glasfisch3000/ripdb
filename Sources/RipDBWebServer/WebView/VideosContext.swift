import struct Foundation.UUID
import RipLib

struct VideosContext: Encodable {
    let sidebarLocation: SidebarLocation = .videos
    var videos: [Video.WebDTO]
}

extension VideosContext {
    struct Singular: Encodable {
        let sidebarLocation: SidebarLocation = .videos
        var id: UUID
        var video: Video.WebDTO
    }
}
