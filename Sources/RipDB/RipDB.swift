import ArgumentParser

@main
struct RipDB: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "ripdb",
//        abstract: <#T##String#>,
//        usage: <#T##String?#>,
//        discussion: <#T##String#>,
        version: "0.0.0",
        shouldDisplay: true,
        subcommands: [Serve.self, Routes.self, Migrate.self],
        groupedSubcommands: [
            CommandGroup(name: "Database", subcommands: [Collections.self, Projects.self, Videos.self, Files.self, Locations.self])
        ],
        defaultSubcommand: nil,
        helpNames: .shortAndLong,
        aliases: []
    )
    
    init() { }
}
