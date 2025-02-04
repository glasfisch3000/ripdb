import ArgumentParser
import Vapor
import struct NIOFileSystem.FilePath
import RipDB

public struct FilesCreate: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "create",
        abstract: "Add a new video file to the database.",
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
    
    struct FileOptionGroup: ParsableArguments {
        @ArgumentParser.Option(name: [.long, .customShort("R")])
        var resolution: FileResolution
        
        @ArgumentParser.Option(name: [.customLong("size"), .customShort("S")])
        var filesize: ParsableFileSize
        
        @ArgumentParser.Option(name: .customLong("sha256"))
        var contentHashSHA256: Data
        
        @ArgumentParser.Option(name: .customLong("3d"))
        var is3D: Bool = false
        
        @ArgumentParser.Option(name: [.long, .customShort("L")])
        var location: UUID
        
        @ArgumentParser.Option(name: [.long, .customShort("V")])
        var video: UUID
    }
    
    @ArgumentParser.Option(name: [.short, .customLong("env")])
    private var environment: ParsableEnvironment?
    
    @ArgumentParser.Option(name: .shortAndLong)
    private var configFile: FilePath?
    
    @ArgumentParser.Option(name: [.customShort("f"), .customLong("format")])
    private var outputFormat: OutputFormat = .yaml
    
    @ArgumentParser.OptionGroup(title: "File Options")
    private var file: FileOptionGroup
    
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
            
            let file = File(id: nil,
                            resolution: self.file.resolution,
                            is3D: self.file.is3D,
                            size: self.file.filesize.bytes,
                            contentHashSHA256: self.file.contentHashSHA256,
                            locationID: self.file.location,
                            videoID: self.file.video)
            try await file.create(on: app.db)
            
            print(try outputFormat.format(file.toDTO()))
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }
        
        try await app.asyncShutdown()
    }
}
