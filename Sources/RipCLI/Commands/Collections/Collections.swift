import ArgumentParser

public struct Collections: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "collections",
        abstract: "Work with project collections.",
//        usage: <#T##String?#>,
//        discussion: <#T##String#>,
        version: "0.0.0",
        shouldDisplay: true,
        subcommands: [CollectionsList.self, CollectionsGet.self, CollectionsCreate.self, CollectionsUpdate.self, CollectionsDelete.self],
        groupedSubcommands: [],
        defaultSubcommand: nil,
        helpNames: .shortAndLong,
        aliases: []
    )
    
    public init() { }
}
