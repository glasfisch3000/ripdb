import RipLib
import struct Foundation.UUID
import protocol Vapor.Content

extension Project {
    struct WebDTO: Sendable, Content {
        enum VideoDictCodingKeys: String, CodingKey {
            case main
            case episode
            case extra
            case trailer
            case advertisement
        }
        
        var id: UUID?
        var name: String
        var type: ProjectType
        var releaseYear: Int
        
        var collection: CollectionModel.WebDTO?
        var videos: [VideoType: [Video.WebDTO]]?
        
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encodeIfPresent(self.id, forKey: .id)
            try container.encode(self.name, forKey: .name)
            try container.encode(self.type, forKey: .type)
            try container.encode(self.releaseYear, forKey: .releaseYear)
            try container.encodeIfPresent(self.collection, forKey: .collection)
            
            if let videos = self.videos {
                var videosContainer = container.nestedContainer(keyedBy: VideoDictCodingKeys.self, forKey: .videos)
                
                try videosContainer.encodeIfPresent(videos[.main], forKey: .main)
                try videosContainer.encodeIfPresent(videos[.episode], forKey: .episode)
                try videosContainer.encodeIfPresent(videos[.extra], forKey: .extra)
                try videosContainer.encodeIfPresent(videos[.trailer], forKey: .trailer)
                try videosContainer.encodeIfPresent(videos[.advertisement], forKey: .advertisement)
            }
        }
    }
    
    func toWebDTO() -> WebDTO {
        WebDTO(id: self.id,
               name: self.name,
               type: self.type,
               releaseYear: self.releaseYear,
               collection: self.$collection.value??.toWebDTO(),
               videos: self.$videos.value?.map { $0.toWebDTO() }.grouped(by: \.type))
    }
}
