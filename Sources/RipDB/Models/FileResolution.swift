import ArgumentParser

enum FileResolution: String, Sendable, Codable, ExpressibleByArgument {
    case sd = "SD"
    case hd = "HD"
    case fullHD = "FHD"
    case ultraHD = "UHD"
}
