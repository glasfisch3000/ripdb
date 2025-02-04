import ArgumentParser

public struct Users: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "users",
        abstract: "Work with registered users.",
//        usage: <#T##String?#>,
//        discussion: <#T##String#>,
        version: "0.0.0",
        shouldDisplay: true,
        subcommands: [UsersList.self, UsersGet.self, UsersCreate.self, UsersUpdate.self, UsersDelete.self],
        groupedSubcommands: [],
        defaultSubcommand: nil,
        helpNames: .shortAndLong,
        aliases: []
    )
    
    public init() { }
}
