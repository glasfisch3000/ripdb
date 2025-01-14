import ArgumentParser
import Vapor
import struct NIOFileSystem.FilePath
import RipLib

struct VideosUpdate: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update a video's attributes.",
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
    
    struct VideoOptionGroup: ParsableArguments {
        @ArgumentParser.Option(name: [.long, .customShort("N")])
        var name: String?
        
        @ArgumentParser.Option(name: [.long, .customShort("T")])
        var type: VideoType?
        
        @ArgumentParser.Option(name: [.long, .customShort("P")])
        var project: UUID?
    }
    
    @ArgumentParser.Option(name: [.short, .customLong("env")])
    private var environment: ParsableEnvironment?
    
    @ArgumentParser.Option(name: .shortAndLong)
    private var configFile: FilePath?
    
    @ArgumentParser.Option(name: [.customShort("f"), .customLong("format")])
    private var outputFormat: OutputFormat = .yaml
    
    @ArgumentParser.Argument
    private var videoID: UUID
    
    @ArgumentParser.OptionGroup(title: "Update Options")
    private var videoOptions: VideoOptionGroup
    
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
            try await configureRipDB(app, location: config.database)
            
            guard let video = try await Video.find(videoID, on: app.db) else {
                throw UpdateError.videoNotFound(videoID)
            }
            
            if let name = videoOptions.name {
                video.name = name
            }
            
            if let type = videoOptions.type {
                video.type = type
            }
            
            if let projectID = videoOptions.project {
                guard try await Project.find(projectID, on: app.db) != nil else {
                    throw UpdateError.projectNotFound(projectID)
                }
                video.$project.id = projectID
            }
            
            try await video.update(on: app.db)
            
            print(try outputFormat.format(video.toDTO()))
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }
        
        try await app.asyncShutdown()
    }
}
