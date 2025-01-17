import ArgumentParser

public struct Locations: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "locations",
        abstract: "Work with file locations.",
//        usage: <#T##String?#>,
//        discussion: <#T##String#>,
        version: "0.0.0",
        shouldDisplay: true,
        subcommands: [LocationsList.self, LocationsGet.self, LocationsCreate.self, LocationsUpdate.self, LocationsDelete.self],
        groupedSubcommands: [],
        defaultSubcommand: nil,
        helpNames: .shortAndLong,
        aliases: []
    )
    
    public init() { }
}
