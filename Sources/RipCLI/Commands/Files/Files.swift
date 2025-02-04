import ArgumentParser

public struct Files: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "files",
        abstract: "Work with video files.",
//        usage: <#T##String?#>,
//        discussion: <#T##String#>,
        version: "0.0.0",
        shouldDisplay: true,
        subcommands: [FilesList.self, FilesGet.self, FilesCreate.self, FilesUpdate.self, FilesDelete.self],
        groupedSubcommands: [],
        defaultSubcommand: nil,
        helpNames: .shortAndLong,
        aliases: []
    )
    
    public init() { }
}
