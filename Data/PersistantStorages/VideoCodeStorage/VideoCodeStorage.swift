import Foundation

public protocol VideoCodeStorage {
    
    func save(
        videoCode: String,
        completion: @escaping (Result<String, Error>) -> Void
    )
    
    func fetch(
        completion: @escaping (Result<[String], Error>) -> Void
    )
}
