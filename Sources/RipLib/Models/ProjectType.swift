import ArgumentParser

public enum ProjectType: String, Sendable, Codable, ExpressibleByArgument {
    case season
    case movie
}
