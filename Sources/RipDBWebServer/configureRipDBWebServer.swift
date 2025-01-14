import Vapor

public func configureRipDBWebServer(_ app: Application) throws {
    app.views.use(.leaf)
    
    let fileMiddleware = FileMiddleware(publicDirectory: app.directory.publicDirectory, advancedETagComparison: true)
    app.middleware.use(fileMiddleware)
    
    try app.register(collection: WebViewController())
}
