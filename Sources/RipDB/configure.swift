import NIOSSL
import Fluent
import FluentPostgresDriver
import Vapor

public func configureDB(_ app: Application, _ config: AppConfig) async throws {
    app.databases.use(
        .postgres(
            configuration: .init(
                hostname: config.database.host,
                port: Int(config.database.port),
                username: config.database.user,
                password: config.database.password,
                database: config.database.database
            )
        ), as: .psql
    )
}

func configureRoutes(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.get { req async in
        "It works!"
    }
}
