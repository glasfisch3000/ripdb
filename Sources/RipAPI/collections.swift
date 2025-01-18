import Vapor
import Fluent
import FluentPostgresDriver
import RipLib

@Sendable
func collectionsList(request req: Request) async throws(APIError) -> some Content {
    do {
        let collections = try await CollectionModel.query(on: req.db)
            .sort(\.$name)
            .all()
        
        return collections.map { $0.toDTO() }
    } catch {
        throw .unknown(error)
    }
}

@Sendable
func collectionsGet(request req: Request) async throws(APIError) -> some Content {
    guard let id = req.parameters.get("id", as: UUID.self) else {
        throw APIError.invalidQuery
    }
    
    do {
        guard let collection = try await CollectionModel.find(id, on: req.db) else {
            throw APIError.modelNotFound(type: .collection, id: id)
        }
        
        try await collection.$projects.load(on: req.db)
        
        return collection.toDTO()
    } catch let error as APIError {
        throw error
    } catch {
        throw .unknown(error)
    }
}

@Sendable
func collectionsGetProjects(request req: Request) async throws(APIError) -> some Content {
    guard let id = req.parameters.get("id", as: UUID.self) else {
        throw APIError.invalidQuery
    }
    
    do {
        guard let collection = try await CollectionModel.find(id, on: req.db) else {
            throw APIError.modelNotFound(type: .collection, id: id)
        }
        
        let projects = try await collection.$projects.query(on: req.db)
            .sort(\.$name)
            .all()
        
        return projects.map { $0.toDTO() }
    } catch let error as APIError {
        throw error
    } catch {
        throw .unknown(error)
    }
}

@Sendable
func collectionsCreate(request req: Request) async throws(APIError) -> some Content {
    struct Parameters: Codable {
        var name: String
    }
    guard let params = try? req.query.decode(Parameters.self) else {
        throw APIError.invalidQuery
    }
    
    do {
        let collection = CollectionModel(name: params.name)
        try await collection.create(on: req.db)
        
        return collection.toDTO()
    } catch let error as APIError {
        throw error
    } catch {
        throw .unknown(error)
    }
}

@Sendable
func collectionsUpdate(request req: Request) async throws(APIError) -> some Content {
    struct Parameters: Codable {
        var id: UUID
        var name: String?
    }
    guard let params = try? req.query.decode(Parameters.self) else {
        throw APIError.invalidQuery
    }
    
    do {
        guard let collection = try await CollectionModel.find(params.id, on: req.db) else {
            throw APIError.modelNotFound(type: .collection, id: params.id)
        }
        
        if let name = params.name {
            collection.name = name
        }
        
        try await collection.update(on: req.db)
        
        return collection.toDTO()
    } catch let error as APIError {
        throw error
    } catch {
        throw .unknown(error)
    }
}

@Sendable
func collectionsDelete(request req: Request) async throws(APIError) -> some Content {
    guard let id = req.parameters.get("id", as: UUID.self) else {
        throw APIError.invalidQuery
    }
    
    do {
        guard let collection = try await CollectionModel.find(id, on: req.db) else {
            throw APIError.modelNotFound(type: .collection, id: id)
        }
        try await collection.delete(on: req.db)
        
        return collection.toDTO()
    } catch let error as APIError {
        throw error
    } catch {
        throw .unknown(error)
    }
}
