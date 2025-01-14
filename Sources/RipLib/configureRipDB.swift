//
//  configureRipDB.swift
//  ripdb
//
//  Created by Jakob Danckwerts on 14.01.25.
//

import class Vapor.Application
import FluentPostgresDriver

public func configureRipDB(_ app: Application, location: PostgresDBLocation) async throws {
    app.databases.use(
        .postgres(configuration: .init(
            hostname: location.host,
            port: Int(location.port),
            username: location.user,
            password: location.password,
            database: location.database
        )), as: .psql
    )
    
    app.migrations.add(CreateLocation())
    app.migrations.add(CreateCollection())
    app.migrations.add(CreateProject())
    app.migrations.add(CreateVideo())
    app.migrations.add(CreateFile())
    app.migrations.add(ChangeProjectDateToYear())
    app.migrations.add(ChangeFilesizeDoubleToInt())
    app.migrations.add(UniqueLocationName())
}
