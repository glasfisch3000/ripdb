import RipLib
import struct Foundation.UUID
import protocol Vapor.Content

extension File {
    struct WebDTO: Sendable, Content {
        var id: UUID?
        var resolution: FileResolution
        var is3D: Bool
        var size: Int
        var contentHashSHA256: String
        
        var location: Location.WebDTO?
        var video: Video.WebDTO?
    }
    
    func toWebDTO() -> WebDTO {
        WebDTO(id: self.id,
               resolution: self.resolution,
               is3D: self.is3D,
               size: self.size,
               contentHashSHA256: self.contentHashSHA256.hexEncodedString(),
               location: self.$location.value?.toWebDTO(),
               video: self.$video.value?.toWebDTO())
    }
}
