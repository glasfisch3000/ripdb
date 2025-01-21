import struct Foundation.UUID
import struct Foundation.Data
import protocol Vapor.Content

extension User {
    public struct DTO: Codable, Content {
        public var id: UUID?
        public var name: String
        public var password: Data?
        public var salt: UUID?
    }
    
    public func toDTO() -> DTO {
        DTO(id: self.$id.value,
            name: self.name,
            password: self.password,
            salt: self.salt)
    }
}
