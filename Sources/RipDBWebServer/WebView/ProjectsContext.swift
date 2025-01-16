import struct Foundation.UUID
import RipLib

struct ProjectsContext: Encodable {
    let sidebarLocation: SidebarLocation = .projects
    var projects: [Project.WebDTO]
}

extension ProjectsContext {
    struct Singular: Encodable {
        let sidebarLocation: SidebarLocation = .projects
        var id: UUID
        var project: Project.WebDTO
    }
}
