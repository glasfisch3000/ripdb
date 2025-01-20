import struct Foundation.UUID

enum APIError: Error, Encodable {
    case unknown(any Error)
    enum UnknownCodingKeys: CodingKey { }
    
    case invalidQuery
    
    case modelNotFound(type: ModelType, id: UUID)
    enum ModelType: String, Encodable {
        case location
        case collection
        case project
        case video
        case file
    }
    
    case constraintViolation(_ constraint: Constraint)
    enum Constraint: Encodable {
        case location_title_unique(_ title: String)
    }
    
    case invalidAuthentication
}
