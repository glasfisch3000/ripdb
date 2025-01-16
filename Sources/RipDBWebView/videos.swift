import Vapor
import Fluent
import RipLib

@Sendable
func videosList(request req: Request) async throws -> View {
    let videos = try await Video.query(on: req.db)
        .with(\.$project)
        .join(parent: \.$project)
        .sort(Project.self, \.$name)
        .sort(\.$type)
        .sort(\.$name)
        .all()
    
    let context = VideosContext(videos: videos.map { $0.toWebDTO() })
    return try await req.view.render("videos", context)
}

@Sendable
func videosGet(request req: Request) async throws -> View {
    guard let id = req.parameters.get("id", as: UUID.self) else {
        return try await req.view.render("invalidID", InvalidIDContext(type: "video", sidebarLocation: .videos))
    }
    
    guard let video = try await Video.find(id, on: req.db) else {
        return try await req.view.render("notFound", NotFoundContext(type: "video", id: id, sidebarLocation: .videos))
    }
    
    try await video.$project.load(on: req.db)
    _ = try await video.$files.get(on: req.db).get().map { file in
        file.$location.load(on: req.db)
    }
    .flatten(on: req.eventLoop)
    .get()
    
    let context = VideosContext.Singular(id: id, video: video.toWebDTO())
    return try await req.view.render("video", context)
}

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
