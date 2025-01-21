import Vapor
import Fluent
import FluentPostgresDriver
import RipDB

@Sendable
func locationsList(request req: Request) async throws(APIError) -> some Content {
    do {
        let locations = try await Location.query(on: req.db)
            .sort(\.$name)
            .all()
        
        return locations.map { $0.toDTO() }
    } catch {
        throw .unknown(error)
    }
}

@Sendable
func locationsGet(request req: Request) async throws(APIError) -> some Content {
    guard let id = req.parameters.get("id", as: UUID.self) else {
        throw APIError.invalidQuery
    }
    
    do {
        guard let location = try await Location.find(id, on: req.db) else {
            throw APIError.modelNotFound(type: .location, id: id)
        }
        
        try await location.$files.load(on: req.db)
        
        return location.toDTO()
    } catch let error as APIError {
        throw error
    } catch {
        throw .unknown(error)
    }
}

@Sendable
func locationsGetFiles(request req: Request) async throws(APIError) -> some Content {
    guard let id = req.parameters.get("id", as: UUID.self) else {
        throw APIError.invalidQuery
    }
    
    do {
        guard let location = try await Location.find(id, on: req.db) else {
            throw APIError.modelNotFound(type: .location, id: id)
        }
        
        let files = try await location.$files.query(on: req.db)
            .with(\.$video)
            .sort(\.$size, .descending)
            .all()
        
        return files.map { $0.toDTO() }
    } catch let error as APIError {
        throw error
    } catch {
        throw .unknown(error)
    }
}

@Sendable
func locationsCreate(request req: Request) async throws(APIError) -> some Content {
    struct Parameters: Codable {
        var name: String
        var capacity: Int?
    }
    guard let params = try? req.query.decode(Parameters.self) else {
        throw APIError.invalidQuery
    }
    
    do {
        let location = Location(name: params.name, capacity: params.capacity)
        try await location.create(on: req.db)
        
        return location.toDTO()
    } catch let error as APIError {
        throw error
    } catch let error as PSQLError where error.serverInfo?[.sqlState] == "23505" {
        throw APIError.constraintViolation(.location_title_unique(params.name))
    } catch {
        throw .unknown(error)
    }
}

@Sendable
func locationsUpdate(request req: Request) async throws(APIError) -> some Content {
    struct Parameters: Codable {
        var id: UUID
        var name: String?
        var capacity: Int??
    }
    guard let params = try? req.query.decode(Parameters.self) else {
        throw APIError.invalidQuery
    }
    
    do {
        guard let location = try await Location.find(params.id, on: req.db) else {
            throw APIError.modelNotFound(type: .location, id: params.id)
        }
        
        if let name = params.name {
            location.name = name
        }
        if let capacity = location.capacity {
            location.capacity = capacity
        }
        
        do {
            try await location.update(on: req.db)
        } catch let error as PSQLError where error.serverInfo?[.sqlState] == "23505" {
            throw APIError.constraintViolation(.location_title_unique(location.name))
        }
        
        return location.toDTO()
    } catch let error as APIError {
        throw error
    } catch {
        throw .unknown(error)
    }
}

@Sendable
func locationsDelete(request req: Request) async throws(APIError) -> some Content {
    guard let id = req.parameters.get("id", as: UUID.self) else {
        throw APIError.invalidQuery
    }
    
    do {
        guard let location = try await Location.find(id, on: req.db) else {
            throw APIError.modelNotFound(type: .location, id: id)
        }
        try await location.delete(on: req.db)
        
        return location.toDTO()
    } catch let error as APIError {
        throw error
    } catch {
        throw .unknown(error)
    }
}
