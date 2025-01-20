import ArgumentParser

@main
public struct RipDB: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "ripdb",
//        abstract: <#T##String#>,
//        usage: <#T##String?#>,
//        discussion: <#T##String#>,
        version: "0.0.0",
        shouldDisplay: true,
        subcommands: [Serve.self, Routes.self, Migrate.self],
        groupedSubcommands: [
            CommandGroup(name: "Database", subcommands: [Users.self, Collections.self, Projects.self, Videos.self, Files.self, Locations.self, Cum.self])
        ],
        defaultSubcommand: nil,
        helpNames: .shortAndLong,
        aliases: []
    )
    
    public init() { }
}
