import ArgumentParser
import Vapor
import Fluent
import NIOFileSystem

struct FilesList: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List video files stored in the database.",
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
    
    struct FilterOptions: ParsableArguments {
        @ArgumentParser.Option(name: [.long, .customShort("L")]) // TODO: add description, 0 = no limit
        var limit: UInt = 100
        
        @ArgumentParser.Option(name: [.long, .customShort("V")])
        var video: UUID?
        
        @ArgumentParser.Option(name: [.long, .customShort("l")])
        var location: UUID?
        
        @ArgumentParser.Flag(name: .customLong("3d"), inversion: .prefixedNo, exclusivity: .exclusive)
        var is3D: Bool?
    }
    
    // TODO: sorting options
    
    @ArgumentParser.Option(name: [.short, .customLong("env")])
    private var environment: ParsableEnvironment?
    
    @ArgumentParser.Option(name: .shortAndLong)
    private var configFile: FilePath?
    
    @ArgumentParser.Option(name: [.customShort("f"), .customLong("format")])
    private var outputFormat: OutputFormat = .yaml
    
    @ArgumentParser.OptionGroup(title: "Filtering Options")
    private var filterOptions: FilterOptions
    
    init() { }
    
    func run() async throws {
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
            try await configureDB(app, config)
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }
        
        var query = File.query(on: app.db)
        
        if let videoID = filterOptions.video {
            query = query.filter(\File.$video.$id == videoID)
        }
        
        if let locationID = filterOptions.location {
            query = query.filter(\File.$location.$id == locationID)
        }
        
        if let is3D = filterOptions.is3D {
            query = query.filter(\File.$is3D == is3D)
        }
        
        let files = try await query
            .with(\.$location)
            .with(\.$video)
            .range(lower: 0, upper: filterOptions.limit == 0 ? nil : Int(filterOptions.limit))
            .all()
            .map { $0.toDTO() }
        print(try outputFormat.format(files))
        
        try await app.asyncShutdown()
    }
}
