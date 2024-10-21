import Foundation
import ArgumentParser

extension Data: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        self.init(base64Encoded: argument)
    }
}
