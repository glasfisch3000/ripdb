import ArgumentParser
import Vapor
import struct NIOFileSystem.FilePath
import RipDB

public struct ProjectsUpdate: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update a project's attributes.",
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
    
    struct ProjectOptionGroup: ParsableArguments {
        @ArgumentParser.Option(name: [.long, .customShort("N")])
        var name: String?
        
        @ArgumentParser.Option(name: [.long, .customShort("T")])
        var type: ProjectType?
        
        @ArgumentParser.Option(name: [.customLong("year"), .customShort("Y")])
        var releaseYear: Int?
        
        @ArgumentParser.Option(name: [.long, .customShort("P")])
        var collection: UUID?
    }
    
    @ArgumentParser.Option(name: [.short, .customLong("env")])
    private var environment: ParsableEnvironment?
    
    @ArgumentParser.Option(name: .shortAndLong)
    private var configFile: FilePath?
    
    @ArgumentParser.Option(name: [.customShort("f"), .customLong("format")])
    private var outputFormat: OutputFormat = .yaml
    
    @ArgumentParser.Argument
    private var projectID: UUID
    
    @ArgumentParser.OptionGroup(title: "Update Options")
    private var projectOptions: ProjectOptionGroup
    
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
            
            guard let project = try await Project.find(projectID, on: app.db) else {
                throw DBError.modelNotFound(.project, id: projectID)
            }
            
            if let name = projectOptions.name {
                project.name = name
            }
            
            if let type = projectOptions.type {
                project.type = type
            }
            
            if let releaseYear = projectOptions.releaseYear {
                project.releaseYear = releaseYear
            }
            
            if let collectionID = projectOptions.collection {
                guard try await CollectionModel.find(collectionID, on: app.db) != nil else {
                    throw DBError.modelNotFound(.collection, id: collectionID)
                }
                project.$collection.id = collectionID
            }
            
            try await project.update(on: app.db)
            
            print(try outputFormat.format(project.toDTO()))
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }
        
        try await app.asyncShutdown()
    }
}
