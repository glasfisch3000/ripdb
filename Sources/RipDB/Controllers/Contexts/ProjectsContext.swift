import struct Foundation.UUID

extension APIContext {
    struct Projects: Encodable {
        let sidebarLocation: APIContext.SidebarLocation = .projects
        var projects: [ProjectDTO.WebView]
    }
}

extension APIContext.Projects {
    struct Singular: Encodable {
        let sidebarLocation: APIContext.SidebarLocation = .projects
        var id: UUID
        var project: ProjectDTO.WebView
    }
}
