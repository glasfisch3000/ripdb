import Vapor

public struct APIController: RouteCollection {
    public func boot(routes: any RoutesBuilder) throws {
        let locations = routes.grouped("locations")
        locations.get(use: locationsList(request:))
        locations.post(use: locationsCreate(request:))
        locations.get(":id", use: locationsGet(request:))
        locations.get(":id", "files", use: locationsGetFiles(request:))
        locations.patch(":id", use: locationsUpdate(request:))
        locations.delete(":id", use: locationsDelete(request:))
        
        let files = routes.grouped("files")
        files.get(use: filesList(request:))
        files.post(use: filesCreate(request:))
        files.get(":id", use: filesGet(request:))
        files.patch(":id", use: filesUpdate(request:))
        files.delete(":id", use: filesDelete(request:))
        
        let videos = routes.grouped("videos")
        videos.get(use: videosList(request:))
        videos.post(use: videosCreate(request:))
        videos.get(":id", use: videosGet(request:))
        videos.get(":id", "files", use: videosGetFiles(request:))
        videos.patch(":id", use: videosUpdate(request:))
        videos.delete(":id", use: videosDelete(request:))
        
        let projects = routes.grouped("projects")
        projects.get(use: projectsList(request:))
        projects.post(use: projectsCreate(request:))
        projects.get(":id", use: projectsGet(request:))
        projects.get(":id", "videos", use: projectsGetVideos(request:))
        projects.patch(":id", use: projectsUpdate(request:))
        projects.delete(":id", use: projectsDelete(request:))
        
        let collections = routes.grouped("collections")
        collections.get(use: collectionsList(request:))
        collections.post(use: collectionsCreate(request:))
        collections.get(":id", use: collectionsGet(request:))
        collections.get(":id", "projects", use: collectionsGetProjects(request:))
        collections.patch(":id", use: collectionsUpdate(request:))
        collections.delete(":id", use: collectionsDelete(request:))
    }
    
    public init() { }
}
