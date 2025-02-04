import ArgumentParser
import Vapor
import Fluent
import struct NIOFileSystem.FilePath
import RipDB

public struct Cum: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "cum",
        abstract: "Yoink out all database contents",
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
    
    @ArgumentParser.Option(name: [.short, .customLong("env")])
    private var environment: ParsableEnvironment?
    
    @ArgumentParser.Option(name: .shortAndLong)
    private var configFile: FilePath?
    
    @ArgumentParser.Option(name: [.customShort("f"), .customLong("format")])
    private var outputFormat: OutputFormat = .yaml
    
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
            
            let collections = Task {
                try await CollectionModel.query(on: app.db)
                    .all()
                    .map { $0.toDTO() }
            }
            
            let projects = Task {
                try await Project.query(on: app.db)
                    .all()
                    .map { $0.toDTO() }
            }
            
            let videos = Task {
                try await Video.query(on: app.db)
                    .all()
                    .map { $0.toDTO() }
            }
            
            let files = Task {
                try await File.query(on: app.db)
                    .all()
                    .map { $0.toDTO() }
            }
            
            let locations = Task {
                try await Location.query(on: app.db)
                    .all()
                    .map { $0.toDTO() }
            }
            
            print("Collections:")
            switch await collections.result {
            case .success(let value): print(try outputFormat.format(value))
            case .failure(let error): print(error)
            }
            
            print("Project:")
            switch await projects.result {
            case .success(let value): print(try outputFormat.format(value))
            case .failure(let error): print(error)
            }
            
            print("Videos:")
            switch await videos.result {
            case .success(let value): print(try outputFormat.format(value))
            case .failure(let error): print(error)
            }
            
            print("Files:")
            switch await files.result {
            case .success(let value): print(try outputFormat.format(value))
            case .failure(let error): print(error)
            }
            
            print("Locations:")
            switch await locations.result {
            case .success(let value): print(try outputFormat.format(value))
            case .failure(let error): print(error)
            }
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }
        
        try await app.asyncShutdown()
    }
}
