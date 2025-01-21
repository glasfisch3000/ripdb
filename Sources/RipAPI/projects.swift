import Vapor
import Fluent
import FluentPostgresDriver
import RipDB

@Sendable
func projectsList(request req: Request) async throws(APIError) -> some Content {
    do {
        let projects = try await Project.query(on: req.db)
            .with(\.$collection)
            .sort(\.$name)
            .all()
        
        return projects.map { $0.toDTO() }
    } catch {
        throw .unknown(error)
    }
}

@Sendable
func projectsGet(request req: Request) async throws(APIError) -> some Content {
    guard let id = req.parameters.get("id", as: UUID.self) else {
        throw APIError.invalidQuery
    }
    
    do {
        guard let project = try await Project.find(id, on: req.db) else {
            throw APIError.modelNotFound(type: .project, id: id)
        }
        
        try await project.$collection.load(on: req.db)
        
        return project.toDTO()
    } catch let error as APIError {
        throw error
    } catch {
        throw .unknown(error)
    }
}

@Sendable
func projectsGetVideos(request req: Request) async throws(APIError) -> some Content {
    guard let id = req.parameters.get("id", as: UUID.self) else {
        throw APIError.invalidQuery
    }
    
    do {
        guard let project = try await Project.find(id, on: req.db) else {
            throw APIError.modelNotFound(type: .project, id: id)
        }
        
        let videos = try await project.$videos.query(on: req.db)
            .sort(\.$name)
            .all()
        
        return videos.map { $0.toDTO() }
    } catch let error as APIError {
        throw error
    } catch {
        throw .unknown(error)
    }
}

@Sendable
func projectsCreate(request req: Request) async throws(APIError) -> some Content {
    struct Parameters: Codable {
        var name: String
        var type: ProjectType
        var releaseYear: Int
        var collectionID: UUID?
    }
    guard let params = try? req.query.decode(Parameters.self) else {
        throw APIError.invalidQuery
    }
    
    do {
        let project = Project(name: params.name, type: params.type, releaseYear: params.releaseYear, collectionID: params.collectionID)
        try await project.create(on: req.db)
        
        return project.toDTO()
    } catch let error as APIError {
        throw error
    } catch {
        throw .unknown(error)
    }
}

@Sendable
func projectsUpdate(request req: Request) async throws(APIError) -> some Content {
    struct Parameters: Codable {
        var id: UUID
        var name: String?
        var type: ProjectType?
        var releaseYear: Int?
        var collectionID: UUID??
    }
    guard let params = try? req.query.decode(Parameters.self) else {
        throw APIError.invalidQuery
    }
    
    do {
        guard let project = try await Project.find(params.id, on: req.db) else {
            throw APIError.modelNotFound(type: .project, id: params.id)
        }
        
        if let name = params.name {
            project.name = name
        }
        if let type = params.type {
            project.type = type
        }
        if let releaseYear = params.releaseYear {
            project.releaseYear = releaseYear
        }
        if let collectionID = params.collectionID {
            project.$collection.id = collectionID
        }
        
        try await project.update(on: req.db)
        
        return project.toDTO()
    } catch let error as APIError {
        throw error
    } catch {
        throw .unknown(error)
    }
}

@Sendable
func projectsDelete(request req: Request) async throws(APIError) -> some Content {
    guard let id = req.parameters.get("id", as: UUID.self) else {
        throw APIError.invalidQuery
    }
    
    do {
        guard let project = try await Project.find(id, on: req.db) else {
            throw APIError.modelNotFound(type: .project, id: id)
        }
        try await project.delete(on: req.db)
        
        return project.toDTO()
    } catch let error as APIError {
        throw error
    } catch {
        throw .unknown(error)
    }
}
