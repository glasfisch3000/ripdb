import ArgumentParser

struct ParsableFileSize: ExpressibleByArgument {
    var bytes: Double
    
    init(bytes: Double) {
        self.bytes = bytes
    }
    
    static func bytes(_ bytes: Double) -> Self {
        Self(bytes: bytes)
    }
    
    static func kiloBytes(_ kb: Double) -> Self {
        Self(bytes: kb * 1000)
    }
    
    static func kibiBytes(_ kib: Double) -> Self {
        Self(bytes: kib * 1024)
    }
    
    static func megaBytes(_ mb: Double) -> Self {
        Self(bytes: mb * 1000 * 1000)
    }
    
    static func mebiBytes(_ mib: Double) -> Self {
        Self(bytes: mib * 1024 * 1024)
    }
    
    static func gigaBytes(_ gb: Double) -> Self {
        Self(bytes: gb * 1000 * 1000 * 1000)
    }
    
    static func gibiBytes(_ gib: Double) -> Self {
        Self(bytes: gib * 1024 * 1024 * 1024)
    }
    
    static func teraBytes(_ tb: Double) -> Self {
        Self(bytes: tb * 1000 * 1000 * 1000 * 1000)
    }
    
    static func tebiBytes(_ tib: Double) -> Self {
        Self(bytes: tib * 1024 * 1024 * 1024 * 1024)
    }
    
    init?(argument: String) {
        let pattern = /(?<factor>[0-9]+(\.[0-9]+)?) *(?<magnitude>b|bytes?|kb|kib|mb|mib|gb|gib|tb|tib)?/.ignoresCase()
        guard let match = try? pattern.wholeMatch(in: argument) else {
            return nil
        }
        
        guard let factor = Double(match.output.factor) else {
            return nil
        }
        
        switch match.output.magnitude?.lowercased() {
        case .none, "b", "byte", "bytes": self = .bytes(factor)
        case "kb":  self = .kiloBytes(factor)
        case "kib": self = .kibiBytes(factor)
        case "mb":  self = .megaBytes(factor)
        case "mib": self = .mebiBytes(factor)
        case "gb":  self = .gigaBytes(factor)
        case "gib": self = .gibiBytes(factor)
        case "tb":  self = .teraBytes(factor)
        case "tib": self = .tebiBytes(factor)
        default: return nil
        }
    }
}
