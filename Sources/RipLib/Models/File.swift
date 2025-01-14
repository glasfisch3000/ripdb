import Fluent
import Foundation

public final class File: Model, Sendable {
    public static let schema = "files"
    
    @ID(key: .id)
    public var id: UUID?

    @Enum(key: "resolution")
    public var resolution: FileResolution
    
    @Field(key: "is_3d")
    public var is3D: Bool
    
    @Field(key: "size")
    public var size: Int
    
    @Field(key: "content_hash_sha256")
    public var contentHashSHA256: Data
    
    @Parent(key: "location")
    public var location: Location
    
    @Parent(key: "video")
    public var video: Video
    
    public init() { }

    public init(id: UUID? = nil, resolution: FileResolution, is3D: Bool, size: Int, contentHashSHA256: Data, locationID: Location.IDValue?, videoID: Video.IDValue?) {
        self.id = id
        self.resolution = resolution
        self.is3D = is3D
        self.size = size
        self.contentHashSHA256 = contentHashSHA256
        if let locationID = locationID { self.$location.id = locationID }
        if let videoID = videoID { self.$video.id = videoID }
    }
}
