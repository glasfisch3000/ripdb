import struct Foundation.UUID
import RipLib

extension Location {
    struct DTO: Sendable, Encodable {
        var id: UUID?
        var name: String
        var capacity: Int?
        
        var files: [File.DTO]?
    }
    
    func toDTO() -> DTO {
        DTO(id: self.id,
            name: self.name,
            capacity: self.capacity,
            files: self.$files.value?.map { $0.toDTO() })
    }
}
