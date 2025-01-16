import struct Foundation.UUID
import RipLib

struct CollectionsContext: Encodable {
    let sidebarLocation: SidebarLocation = .collections
    var collections: [CollectionModel.WebDTO]
}

extension CollectionsContext {
    struct Singular: Encodable {
        let sidebarLocation: SidebarLocation = .collections
        var id: UUID
        var collection: CollectionModel.WebDTO
    }
}
