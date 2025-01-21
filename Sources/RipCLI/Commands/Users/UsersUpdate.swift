import ArgumentParser
import Vapor
import struct NIOFileSystem.FilePath
import RipDB
import FluentPostgresDriver

public struct UsersUpdate: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "update",
        abstract: "Update a user's attributes.",
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
    
    struct UserOptionGroup: ParsableArguments {
        @ArgumentParser.Option(name: [.long, .customShort("N")])
        var name: String?
        
        @ArgumentParser.Option(name: [.long, .customShort("P")])
        var password: String?
    }
    
    @ArgumentParser.Option(name: [.short, .customLong("env")])
    private var environment: ParsableEnvironment?
    
    @ArgumentParser.Option(name: .shortAndLong)
    private var configFile: FilePath?
    
    @ArgumentParser.Option(name: [.customShort("f"), .customLong("format")])
    private var outputFormat: OutputFormat = .yaml
    
    @ArgumentParser.Argument
    private var userID: UUID
    
    @ArgumentParser.OptionGroup(title: "Update Options")
    private var userOptions: UserOptionGroup
    
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
            
            guard let user = try await User.find(userID, on: app.db) else {
                throw DBError.modelNotFound(.user, id: userID)
            }
            
            if let name = userOptions.name {
                user.name = name
            }
            
            if let password = userOptions.password {
                user.password = User.hashPassword(password, salt: user.salt)
            }
            
            do {
                try await user.update(on: app.db)
            } catch let error as PSQLError where error.serverInfo?[.sqlState] == "23505" {
                if let name = userOptions.name {
                    throw DBError.constraintViolation(.user_name_unique(name))
                } else {
                    throw error
                }
            }
            
            print(try outputFormat.format(user.toDTO()))
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }
        
        try await app.asyncShutdown()
    }
}
