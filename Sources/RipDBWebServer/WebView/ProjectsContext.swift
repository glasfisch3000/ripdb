import struct Foundation.UUID
import RipLib

extension APIContext {
    struct Projects: Encodable {
        let sidebarLocation: APIContext.SidebarLocation = .projects
        var projects: [Project.WebDTO]
    }
}

extension APIContext.Projects {
    struct Singular: Encodable {
        let sidebarLocation: APIContext.SidebarLocation = .projects
        var id: UUID
        var project: Project.WebDTO
    }
}
