import struct Foundation.UUID

enum UpdateError: Error, CustomStringConvertible {
    case locationNotFound(UUID)
    case fileNotFound(UUID)
    case videoNotFound(UUID)
    case projectNotFound(UUID)
    case collectionNotFound(UUID)
    
    var description: String {
        switch self {
        case .locationNotFound(let id): "location not found for id \(id)"
        case .fileNotFound(let id): "file not found for id \(id)"
        case .videoNotFound(let id): "video not found for id \(id)"
        case .projectNotFound(let id): "project not found for id \(id)"
        case .collectionNotFound(let id): "collection not found for id \(id)"
        }
    }
}
