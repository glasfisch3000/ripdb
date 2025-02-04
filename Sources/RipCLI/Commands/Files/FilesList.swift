import ArgumentParser
import Vapor
import Fluent
import struct NIOFileSystem.FilePath
import RipDB

public struct FilesList: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
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
    
    enum SortOption: String, ExpressibleByArgument {
        case res
        case size
        case is3d
    }
    
    enum SortOrder: String, ExpressibleByArgument {
        case ascending
        case descending
        
        var databaseDirection: DatabaseQuery.Sort.Direction {
            switch self {
            case .ascending: .ascending
            case .descending: .descending
            }
        }
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
    
    @ArgumentParser.Option(name: [.customShort("S"), .customLong("sort")])
    private var sortOptions: [SortOption] = []
    
    @ArgumentParser.Option(name: [.long])
    private var sortOrder: SortOrder = .ascending
    
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
            
            var query = File.query(on: app.db)
            
            if let videoID = filterOptions.video {
                query = query.filter(\.$video.$id == videoID)
            }
            
            if let locationID = filterOptions.location {
                query = query.filter(\.$location.$id == locationID)
            }
            
            if let is3D = filterOptions.is3D {
                query = query.filter(\.$is3D == is3D)
            }
            
            for sortOption in sortOptions {
                query = switch sortOption {
                case .res: query.sort(\.$resolution, sortOrder.databaseDirection)
                case .size: query.sort(\.$size, sortOrder.databaseDirection)
                case .is3d: query.sort(\.$is3D, sortOrder.databaseDirection)
                }
            }
            
            let files = try await query
                .with(\.$location)
                .with(\.$video)
                .range(lower: 0, upper: filterOptions.limit == 0 ? nil : Int(filterOptions.limit))
                .all()
                .map { $0.toDTO() }
            print(try outputFormat.format(files))
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }
        
        try await app.asyncShutdown()
    }
}
