import ArgumentParser
import Vapor
import struct NIOFileSystem.FilePath
import RipDB
import FluentPostgresDriver

public struct LocationsUpdate: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update a location's attributes.",
//        usage: <#T##String?#>,
//        discussion: <#T##String#>,
        version: "0.0.0",
        shouldDisplay: true,
        subcommands: [],
        groupedSubcommands: [],
        defaultSubcommand: nil,
        helpNames: .shortAndLong,
        aliases: []
    )
    
    struct LocationOptionGroup: ParsableArguments {
        @ArgumentParser.Option(name: [.long, .customShort("N")])
        var name: String?
        
        @ArgumentParser.Option(name: [.long, .customShort("C")])
        var capacity: ParsableFileSize.Optional?
    }
    
    @ArgumentParser.Option(name: [.short, .customLong("env")])
    private var environment: ParsableEnvironment?
    
    @ArgumentParser.Option(name: .shortAndLong)
    private var configFile: FilePath?
    
    @ArgumentParser.Option(name: [.customShort("f"), .customLong("format")])
    private var outputFormat: OutputFormat = .yaml
    
    @ArgumentParser.Argument
    private var locationID: UUID
    
    @ArgumentParser.OptionGroup(title: "Update Options")
    private var locationOptions: LocationOptionGroup
    
    public init() { }
    
    public func run() async throws {
        let config = try await readAppConfig(path: configFile)
        
        let environment = self.environment ?? config.environment
        var env = environment.makeEnvironment()
        env.commandInput.arguments = []
        
        try LoggingSystem.bootstrap(from: &env)
        let app = try await Application.make(env)

        // This attempts to install NIO as the Swift Concurrency global executor.
        // You can enable it if you'd like to reduce the amount of context switching between NIO and Swift Concurrency.
        // Note: this has caused issues with some libraries that use `.wait()` and cleanly shutting down.
        // If enabled, you should be careful about calling async functions before this point as it can cause assertion failures.
        // let executorTakeoverSuccess = NIOSingletons.unsafeTryInstallSingletonPosixEventLoopGroupAsConcurrencyGlobalExecutor()
        // app.logger.debug("Tried to install SwiftNIO's EventLoopGroup as Swift's global concurrency executor", metadata: ["success": .stringConvertible(executorTakeoverSuccess)])
        
        do {
            try await configureRipDB(app, location: config.database)
            
            guard let location = try await Location.find(locationID, on: app.db) else {
                throw DBError.modelNotFound(.location, id: locationID)
            }
            
            if let name = locationOptions.name {
                location.name = name
            }
            
            if let capacity = locationOptions.capacity {
                location.capacity = capacity.bytes
            }
            
            do {
                try await location.update(on: app.db)
            } catch let error as PSQLError where error.serverInfo?[.sqlState] == "23505" {
                if let name = locationOptions.name {
                    throw DBError.constraintViolation(.location_name_unique(name))
                } else {
                    throw error
                }
            }
            
            print(try outputFormat.format(location.toDTO()))
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }
        
        try await app.asyncShutdown()
    }
}
