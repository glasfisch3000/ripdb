import struct Foundation.UUID
import RipLib

extension CollectionModel {
    struct DTO: Sendable, Encodable {
        var id: UUID?
        var name: String
        
        var projects: [Project.DTO]?
    }
    
    func toDTO() -> DTO {
        DTO(id: self.id,
            name: self.name,
            projects: self.$projects.value?.map { $0.toDTO() })
    }
}
