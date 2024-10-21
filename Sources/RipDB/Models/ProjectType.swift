import ArgumentParser

enum ProjectType: String, Sendable, Codable, ExpressibleByArgument {
    case season
    case movie
}
