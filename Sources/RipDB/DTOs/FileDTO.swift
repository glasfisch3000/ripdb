import struct Foundation.UUID
import struct Foundation.Data
import RipLib

extension File {
    struct DTO: Sendable, Encodable {
        var id: UUID?
        var resolution: FileResolution
        var is3D: Bool
        var size: Int
        var contentHashSHA256: Data
        
        var location: Location.DTO?
        var video: Video.DTO?
    }
    
    func toDTO() -> DTO {
        DTO(id: self.id,
            resolution: self.resolution,
            is3D: self.is3D,
            size: self.size,
            contentHashSHA256: self.contentHashSHA256,
            location: self.$location.value?.toDTO(),
            video: self.$video.value?.toDTO())
    }
}
