import ArgumentParser
import Vapor
import struct NIOFileSystem.FilePath

import RipDB
import RipWebView
import RipAPI

public struct Serve: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "serve",
        abstract: "Start running the RipDB server.",
//        usage: <#T##String?#>,
//        discussion: <#T##String#>,
        version: "0.0.0",
        shouldDisplay: true,
        subcommands: [],
        groupedSubcommands: [],
        defaultSubcommand: nil,
        helpNames: .shortAndLong,
        aliases: ["run"]
    )
    
    enum MigrationFlag: String, EnumerableFlag {
        case migrate
        case revert
    }
    
    @ArgumentParser.Option(name: [.short, .customLong("env")])
    private var environment: ParsableEnvironment?
    
    @ArgumentParser.Option(name: .shortAndLong)
    private var configFile: FilePath?
    
    @ArgumentParser.Option(name: .shortAndLong)
    private var port: UInt16 = 8080
    
    @ArgumentParser.Option(name: [.long, .customShort("H")])
    private var hostname: String = "127.0.0.1"
    
    @ArgumentParser.Flag(exclusivity: .exclusive)
    private var migration: MigrationFlag?
    
    public init() { }
    
    public func run() async throws {
        let config = try await readAppConfig(path: configFile)
        
        let environment = self.environment ?? config.environment
        var env = environment.makeEnvironment()
        env.commandInput.arguments = ["serve"]
        
        try LoggingSystem.bootstrap(from: &env)
        let app = try await Application.make(env)
        
        app.http.server.configuration.port = Int(port)
        app.http.server.configuration.hostname = hostname

        // This attempts to install NIO as the Swift Concurrency global executor.
        // You can enable it if you'd like to reduce the amount of context switching between NIO and Swift Concurrency.
        // Note: this has caused issues with some libraries that use `.wait()` and cleanly shutting down.
        // If enabled, you should be careful about calling async functions before this point as it can cause assertion failures.
        // let executorTakeoverSuccess = NIOSingletons.unsafeTryInstallSingletonPosixEventLoopGroupAsConcurrencyGlobalExecutor()
        // app.logger.debug("Tried to install SwiftNIO's EventLoopGroup as Swift's global concurrency executor", metadata: ["success": .stringConvertible(executorTakeoverSuccess)])
        
        do {
            try await configureRipDB(app, location: config.database)
            switch migration {
            case .migrate: try await app.autoMigrate()
            case .revert: try await app.autoRevert()
            case nil: break
            }
            
            try configureRipDBWebView(app)
            try app.grouped("api").register(collection: APIController())
            try await app.execute()
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }
        
        try await app.asyncShutdown()
    }
}
