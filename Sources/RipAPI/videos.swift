import Vapor
import Fluent
import FluentPostgresDriver
import RipDB

@Sendable
func videosList(request req: Request) async throws(APIError) -> some Content {
    do {
        let videos = try await Video.query(on: req.db)
            .with(\.$project)
            .sort(\.$name)
            .all()
        
        return videos.map { $0.toDTO() }
    } catch {
        throw .unknown(error)
    }
}

@Sendable
func videosGet(request req: Request) async throws(APIError) -> some Content {
    guard let id = req.parameters.get("id", as: UUID.self) else {
        throw APIError.invalidQuery
    }
    
    do {
        guard let video = try await Video.find(id, on: req.db) else {
            throw APIError.modelNotFound(type: .video, id: id)
        }
        
        try await video.$project.load(on: req.db)
        
        return video.toDTO()
    } catch let error as APIError {
        throw error
    } catch {
        throw .unknown(error)
    }
}

@Sendable
func videosGetFiles(request req: Request) async throws(APIError) -> some Content {
    guard let id = req.parameters.get("id", as: UUID.self) else {
        throw APIError.invalidQuery
    }
    
    do {
        guard let video = try await Video.find(id, on: req.db) else {
            throw APIError.modelNotFound(type: .video, id: id)
        }
        
        let files = try await video.$files.query(on: req.db)
            .sort(\.$resolution)
            .sort(\.$is3D)
            .all()
        
        return files.map { $0.toDTO() }
    } catch let error as APIError {
        throw error
    } catch {
        throw .unknown(error)
    }
}

@Sendable
func videosCreate(request req: Request) async throws(APIError) -> some Content {
    struct Parameters: Codable {
        var name: String
        var type: VideoType
        var projectID: UUID
    }
    guard let params = try? req.query.decode(Parameters.self) else {
        throw APIError.invalidQuery
    }
    
    do {
        let video = Video(name: params.name, type: params.type, projectID: params.projectID)
        try await video.create(on: req.db)
        
        return video.toDTO()
    } catch let error as APIError {
        throw error
    } catch {
        throw .unknown(error)
    }
}

@Sendable
func videosUpdate(request req: Request) async throws(APIError) -> some Content {
    struct Parameters: Codable {
        var id: UUID
        var name: String?
        var type: VideoType?
        var projectID: UUID?
    }
    guard let params = try? req.query.decode(Parameters.self) else {
        throw APIError.invalidQuery
    }
    
    do {
        guard let video = try await Video.find(params.id, on: req.db) else {
            throw APIError.modelNotFound(type: .project, id: params.id)
        }
        
        if let name = params.name {
            video.name = name
        }
        if let type = params.type {
            video.type = type
        }
        if let projectID = params.projectID {
            video.$project.id = projectID
        }
        
        try await video.update(on: req.db)
        
        return video.toDTO()
    } catch let error as APIError {
        throw error
    } catch {
        throw .unknown(error)
    }
}

@Sendable
func videosDelete(request req: Request) async throws(APIError) -> some Content {
    guard let id = req.parameters.get("id", as: UUID.self) else {
        throw APIError.invalidQuery
    }
    
    do {
        guard let video = try await Video.find(id, on: req.db) else {
            throw APIError.modelNotFound(type: .video, id: id)
        }
        try await video.delete(on: req.db)
        
        return video.toDTO()
    } catch let error as APIError {
        throw error
    } catch {
        throw .unknown(error)
    }
}
