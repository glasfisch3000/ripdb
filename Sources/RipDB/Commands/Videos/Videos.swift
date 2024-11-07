import ArgumentParser
import Vapor
import NIOFileSystem

struct Videos: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "videos",
        abstract: "Work with videos.",
//        usage: <#T##String?#>,
//        discussion: <#T##String#>,
        version: "0.0.0",
        shouldDisplay: true,
        subcommands: [VideosList.self, VideosGet.self, VideosCreate.self, VideosUpdate.self, VideosDelete.self],
        groupedSubcommands: [],
        defaultSubcommand: nil,
        helpNames: .shortAndLong,
        aliases: []
    )
    
    init() { }
}
