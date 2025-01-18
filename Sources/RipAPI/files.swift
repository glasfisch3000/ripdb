import Vapor
import Fluent
import FluentPostgresDriver
import RipLib

@Sendable
func filesList(request req: Request) async throws(APIError) -> some Content {
    do {
        let files = try await File.query(on: req.db)
            .with(\.$video)
            .with(\.$location)
            .sort(\.$size)
            .sort(\.$is3D)
            .all()
        
        return files.map { $0.toDTO() }
    } catch {
        throw .unknown(error)
    }
}

@Sendable
func filesGet(request req: Request) async throws(APIError) -> some Content {
    guard let id = req.parameters.get("id", as: UUID.self) else {
        throw APIError.invalidQuery
    }
    
    do {
        guard let file = try await File.find(id, on: req.db) else {
            throw APIError.modelNotFound(type: .file, id: id)
        }
        
        try await file.$video.load(on: req.db)
        try await file.$location.load(on: req.db)
        
        return file.toDTO()
    } catch let error as APIError {
        throw error
    } catch {
        throw .unknown(error)
    }
}

@Sendable
func filesCreate(request req: Request) async throws(APIError) -> some Content {
    struct Parameters: Codable {
        var resolution: FileResolution
        var is3D: Bool
        var size: Int
        var contentHashSHA256: Data
        var locationID: UUID
        var videoID: UUID
    }
    guard let params = try? req.query.decode(Parameters.self) else {
        throw APIError.invalidQuery
    }
    
    do {
        let file = File(resolution: params.resolution, is3D: params.is3D, size: params.size, contentHashSHA256: params.contentHashSHA256, locationID: params.locationID, videoID: params.videoID)
        try await file.create(on: req.db)
        
        return file.toDTO()
    } catch let error as APIError {
        throw error
    } catch {
        throw .unknown(error)
    }
}

@Sendable
func filesUpdate(request req: Request) async throws(APIError) -> some Content {
    struct Parameters: Codable {
        var id: UUID
        var resolution: FileResolution?
        var is3D: Bool?
        var size: Int?
        var contentHashSHA256: Data?
        var locationID: UUID?
        var videoID: UUID?
    }
    guard let params = try? req.query.decode(Parameters.self) else {
        throw APIError.invalidQuery
    }
    
    do {
        guard let file = try await File.find(params.id, on: req.db) else {
            throw APIError.modelNotFound(type: .file, id: params.id)
        }
        
        if let resolution = params.resolution {
            file.resolution = resolution
        }
        if let is3D = params.is3D {
            file.is3D = is3D
        }
        if let size = params.size {
            file.size = size
        }
        if let contentHashSHA256 = params.contentHashSHA256 {
            file.contentHashSHA256 = contentHashSHA256
        }
        if let locationID = params.locationID {
            file.$location.id = locationID
        }
        if let videoID = params.videoID {
            file.$video.id = videoID
        }
        
        try await file.update(on: req.db)
        
        return file.toDTO()
    } catch let error as APIError {
        throw error
    } catch {
        throw .unknown(error)
    }
}

@Sendable
func filesDelete(request req: Request) async throws(APIError) -> some Content {
    guard let id = req.parameters.get("id", as: UUID.self) else {
        throw APIError.invalidQuery
    }
    
    do {
        guard let file = try await File.find(id, on: req.db) else {
            throw APIError.modelNotFound(type: .file, id: id)
        }
        try await file.delete(on: req.db)
        
        return file.toDTO()
    } catch let error as APIError {
        throw error
    } catch {
        throw .unknown(error)
    }
}
