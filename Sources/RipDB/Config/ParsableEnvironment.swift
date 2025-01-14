import ArgumentParser
import struct Vapor.Environment

public enum ParsableEnvironment: String, Hashable, Sendable, Codable, ExpressibleByArgument {
    case production
    case development
    case testing
    
    public func makeEnvironment() -> Environment {
        switch self {
        case .production: .production
        case .development: .development
        case .testing: .testing
        }
    }
}
