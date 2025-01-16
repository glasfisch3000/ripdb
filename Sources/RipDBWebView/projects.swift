import Vapor
import Fluent
import RipLib

@Sendable
func projectsList(request req: Request) async throws -> View {
    let projects = try await Project.query(on: req.db)
        .with(\.$collection)
        .join(parent: \.$collection)
        .sort(CollectionModel.self, \.$name)
        .sort(\.$releaseYear)
        .sort(\.$name)
        .sort(\.$type)
        .all()
    
    let context = ProjectsContext(projects: projects.map { $0.toWebDTO() })
    return try await req.view.render("projects", context)
}

@Sendable
func projectsGet(request req: Request) async throws -> View {
    guard let id = req.parameters.get("id", as: UUID.self) else {
        return try await req.view.render("invalidID", InvalidIDContext(type: "project", sidebarLocation: .projects))
    }
    
    guard let project = try await Project.find(id, on: req.db) else {
        return try await req.view.render("notFound", NotFoundContext(type: "project", id: id, sidebarLocation: .projects))
    }
    
    try await project.$collection.load(on: req.db)
    try await project.$videos.load(on: req.db)
    
    let context = ProjectsContext.Singular(id: id, project: project.toWebDTO())
    return try await req.view.render("project", context)
}

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
