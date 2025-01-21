import struct Foundation.UUID
import protocol Vapor.Content

extension Video {
    public struct DTO: Sendable, Content {
        public var id: UUID?
        public var name: String
        public var type: VideoType
        
        public var project: Project.DTO?
        public var files: [File.DTO]?
    }
    
    public func toDTO() -> DTO {
        DTO(id: self.id,
            name: self.name,
            type: self.type,
            project: self.$project.value?.toDTO(),
            files: self.$files.value?.map { $0.toDTO() })
    }
}
