import ArgumentParser

struct ParsableFileSize: ExpressibleByArgument {
    var bytes: Int
    
    init(bytes: Int) {
        self.bytes = bytes
    }
    
    static func bytes(_ bytes: Int) -> Self {
        Self(bytes: bytes)
    }
    
    static func kiloBytes(_ kb: Double) -> Self {
        Self(bytes: Int((kb * 1000).rounded()))
    }
    
    static func kibiBytes(_ kib: Double) -> Self {
        Self(bytes: Int((kib * 1024).rounded()))
    }
    
    static func megaBytes(_ mb: Double) -> Self {
        Self(bytes: Int((mb * 1000 * 1000).rounded()))
    }
    
    static func mebiBytes(_ mib: Double) -> Self {
        Self(bytes: Int((mib * 1024 * 1024).rounded()))
    }
    
    static func gigaBytes(_ gb: Double) -> Self {
        Self(bytes: Int((gb * 1000 * 1000 * 1000).rounded()))
    }
    
    static func gibiBytes(_ gib: Double) -> Self {
        Self(bytes: Int((gib * 1024 * 1024 * 1024).rounded()))
    }
    
    static func teraBytes(_ tb: Double) -> Self {
        Self(bytes: Int((tb * 1000 * 1000 * 1000 * 1000).rounded()))
    }
    
    static func tebiBytes(_ tib: Double) -> Self {
        Self(bytes: Int((tib * 1024 * 1024 * 1024 * 1024).rounded()))
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
        case .none, "b", "byte", "bytes":
            guard let bytes = Int(match.output.factor) else {
                return nil
            }
            self.bytes = bytes
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
