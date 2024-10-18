import Fluent
import struct Foundation.Data
import struct Foundation.UUID

final class File: Model, Sendable {
    static let schema = "files"
    
    @ID(key: .id)
    var id: UUID?

    @Enum(key: "resolution")
    var resolution: FileResolution
    
    @Field(key: "is_3d")
    var is3D: Bool
    
    @Field(key: "size")
    var size: UInt64
    
    @Field(key: "content_hash_sha256")
    var contentHashSHA256: Data
    
    @Parent(key: "location")
    var location: Location
    
    @Parent(key: "video")
    var video: Video
    
    init() { }

    init(id: UUID? = nil, resolution: FileResolution, is3D: Bool, size: UInt64, contentHashSHA256: Data, locationID: Location.IDValue?, videoID: Video.IDValue?) {
        self.id = id
        self.resolution = resolution
        self.is3D = is3D
        self.size = size
        self.contentHashSHA256 = contentHashSHA256
        if let locationID = locationID { self.$location.id = locationID }
        if let videoID = videoID { self.$video.id = videoID }
    }
    
    func toDTO() -> FileDTO {
        FileDTO(id: self.id,
                resolution: self.resolution,
                is3D: self.is3D,
                size: self.size,
                contentHashSHA256: self.contentHashSHA256,
                location: self.$location.value?.toDTO(),
                video: self.$video.value?.toDTO())
    }
}
