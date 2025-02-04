import struct Foundation.UUID
import struct Foundation.Data
import protocol Vapor.Content

extension File {
    public struct DTO: Sendable, Content {
        public var id: UUID?
        public var resolution: FileResolution
        public var is3D: Bool
        public var size: Int
        public var contentHashSHA256: Data
        
        public var locationID: UUID?
        public var videoID: UUID?
    }
    
    public func toDTO() -> DTO {
        DTO(id: self.id,
            resolution: self.resolution,
            is3D: self.is3D,
            size: self.size,
            contentHashSHA256: self.contentHashSHA256,
            locationID: self.$location.$id.value,
            videoID: self.$video.$id.value)
    }
}
