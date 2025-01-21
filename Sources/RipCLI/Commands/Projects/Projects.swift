import ArgumentParser

public struct Projects: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "projects",
        abstract: "Work with movie projects.",
//        usage: <#T##String?#>,
//        discussion: <#T##String#>,
        version: "0.0.0",
        shouldDisplay: true,
        subcommands: [ProjectsList.self, ProjectsGet.self, ProjectsCreate.self, ProjectsUpdate.self, ProjectsDelete.self],
        groupedSubcommands: [],
        defaultSubcommand: nil,
        helpNames: .shortAndLong,
        aliases: []
    )
    
    public init() { }
}
