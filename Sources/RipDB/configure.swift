import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

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
}

func configureRoutes(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.get { req async in
        "It works!"
    }
}
