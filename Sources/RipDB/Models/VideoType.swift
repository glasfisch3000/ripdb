import ArgumentParser

public enum VideoType: String, Sendable, Codable, ExpressibleByArgument {
    case main
    case episode
    case extra
    case trailer
    case advertisement
}
