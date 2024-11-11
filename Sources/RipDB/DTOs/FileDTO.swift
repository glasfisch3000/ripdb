import Fluent
import Vapor

struct FileDTO: Sendable, Content {
    var id: UUID?
    var resolution: FileResolution
    var is3D: Bool
    var size: Int
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
    
    func toWebView() -> Self.WebView {
        WebView(id: self.id,
                resolution: self.resolution,
                is3D: self.is3D,
                size: self.size,
                contentHashSHA256: self.contentHashSHA256.hexEncodedString(uppercase: false),
                location: self.location?.toWebView(),
                video: self.video?.toWebView())
    }
}

extension FileDTO {
    struct WebView: Sendable, Content {
        var id: UUID?
        var resolution: FileResolution
        var is3D: Bool
        var size: Int
        var contentHashSHA256: String
        
        var location: LocationDTO.WebView?
        var video: VideoDTO.WebView?
    }
}
