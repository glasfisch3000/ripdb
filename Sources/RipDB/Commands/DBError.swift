import struct Foundation.UUID

enum DBError: Error, CustomStringConvertible {
    enum ModelType: String {
        case user
        case location
        case file
        case video
        case project
        case collection
    }
    case modelNotFound(ModelType, id: UUID)
    
    enum ConstraintViolation {
        case user_name_unique(String)
        case location_name_unique(String)
    }
    case constraintViolation(ConstraintViolation)
    
    var description: String {
        switch self {
        case .modelNotFound(let type, id: let id): "\(type.rawValue) not found for id \(id)"
        case .constraintViolation(.user_name_unique(let name)): "a user with the name \"\(name)\" already exists"
        case .constraintViolation(.location_name_unique(let name)): "a location with the name \"\(name)\" already exists"
        }
    }
}
