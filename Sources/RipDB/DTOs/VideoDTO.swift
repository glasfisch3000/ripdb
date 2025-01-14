import struct Foundation.UUID
import RipLib

extension Video {
    struct DTO: Sendable, Encodable {
        var id: UUID?
        var name: String
        var type: VideoType
        
        var project: Project.DTO?
        var files: [File.DTO]?
    }
    
    func toDTO() -> DTO {
        DTO(id: self.id,
            name: self.name,
            type: self.type,
            project: self.$project.value?.toDTO(),
            files: self.$files.value?.map { $0.toDTO() })
    }
}
