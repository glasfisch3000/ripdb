import Fluent
import Vapor
import Crypto

public final class User: Model, @unchecked Sendable {
    public static let schema = "users"
    
    @ID(key: .id)
    public var id: UUID?

    @Field(key: "name")
    public var name: String
    
    @Field(key: "password")
    public var password: Data
    
    @Field(key: "salt")
    public var salt: UUID

    public init() { }

    public init(id: UUID? = nil, name: String, password: String) {
        self.id = id
        self.name = name
        self.salt = .generateRandom()
        self.password = Self.hashPassword(password, salt: self.salt)
    }
    
    public static func hashPassword(_ string: String, salt: UUID) -> Data {
        var hasher = SHA256()
        hasher.update(data: Data(string.utf8))
        hasher.update(data: Data(salt.uuidString.utf8))
        return Data(hasher.finalize())
    }
}
