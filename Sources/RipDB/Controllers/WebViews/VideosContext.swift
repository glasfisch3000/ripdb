import struct Foundation.UUID

extension APIContext {
    struct Videos: Encodable {
        let sidebarLocation: APIContext.SidebarLocation = .videos
        var videos: [VideoDTO.WebView]
    }
}

extension APIContext.Videos {
    struct Singular: Encodable {
        let sidebarLocation: APIContext.SidebarLocation = .videos
        var id: UUID
        var video: VideoDTO.WebView
    }
}
