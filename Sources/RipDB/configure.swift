import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor
import Leaf

public func configureDB(_ app: Application, _ config: AppConfig) async throws {
    app.databases.use(
        .postgres(configuration: .init(
            hostname: config.database.host,
            port: Int(config.database.port),
            username: config.database.user,
            password: config.database.password,
            database: config.database.database
        )), as: .psql
    )
    
    app.migrations.add(CreateLocation())
    app.migrations.add(CreateCollection())
    app.migrations.add(CreateProject())
    app.migrations.add(CreateVideo())
    app.migrations.add(CreateFile())
    app.migrations.add(ChangeProjectDateToYear())
    app.migrations.add(ChangeFilesizeDoubleToInt())
}

func configureRoutes(_ app: Application) throws {
    app.views.use(.leaf)
    
    let fileMiddleware = FileMiddleware(publicDirectory: app.directory.publicDirectory, advancedETagComparison: true)
    app.middleware.use(fileMiddleware)
    
    try app.register(collection: APIController())
    
    app.get { req async in
        "It works!"
    }
}
