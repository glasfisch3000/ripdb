import Fluent
import Vapor

struct FileDTO: Content {
    var id: UUID?
    var resolution: FileResolution
    var is3D: Bool
    var size: UInt64
    var contentHashSHA256: Data
    var location: LocationDTO?
    var video: VideoDTO?
    
    func toModel() -> File {
        File(id: self.id,
             resolution: self.resolution,
             is3D: self.is3D,
             size: self.size,
             contentHashSHA256: self.contentHashSHA256,
             locationID: self.location?.id,
             videoID: self.video?.id)
    }
}
