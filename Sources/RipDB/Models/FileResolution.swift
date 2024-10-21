import ArgumentParser

enum FileResolution: String, Sendable, Codable, Comparable, ExpressibleByArgument {
    case sd = "SD"
    case hd = "HD"
    case fullHD = "FHD"
    case ultraHD = "UHD"
    
    static func < (lhs: FileResolution, rhs: FileResolution) -> Bool {
        switch (lhs, rhs) {
        case (.sd, .sd): false
        case (.sd, .hd): true
        case (.sd, .fullHD): true
        case (.sd, .ultraHD): true
        case (.hd, .sd): false
        case (.hd, .hd): false
        case (.hd, .fullHD): true
        case (.hd, .ultraHD): true
        case (.fullHD, .sd): false
        case (.fullHD, .hd): false
        case (.fullHD, .fullHD): false
        case (.fullHD, .ultraHD): true
        case (.ultraHD, .sd): false
        case (.ultraHD, .hd): false
        case (.ultraHD, .fullHD): false
        case (.ultraHD, .ultraHD): false
        }
    }
}
