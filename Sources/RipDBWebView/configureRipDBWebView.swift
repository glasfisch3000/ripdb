import Vapor
import Leaf

public func configureRipDBWebView(_ app: Application) throws {
    app.views.use(.leaf)
    
    let fileMiddleware = FileMiddleware(publicDirectory: app.directory.publicDirectory, advancedETagComparison: true)
    app.middleware.use(fileMiddleware)
    
    app.get(use: dashboardGet(request:))
    
    let locations = app.grouped("locations")
    locations.get(use: locationsList(request:))
    locations.get(":id", use: locationsGet(request:))
    locations.get(":id", "files", use: locationsGetFiles(request:))
    
    let files = app.grouped("files")
    files.get(use: filesList(request:))
    files.get(":id", use: filesGet(request:))
    
    let videos = app.grouped("videos")
    videos.get(use: videosList(request:))
    videos.get(":id", use: videosGet(request:))
    
    let projects = app.grouped("projects")
    projects.get(use: projectsList(request:))
    projects.get(":id", use: projectsGet(request:))
    
    let collections = app.grouped("collections")
    collections.get(use: collectionsList(request:))
    collections.get(":id", use: collectionsGet(request:))
}
