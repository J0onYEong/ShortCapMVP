import Foundation

public protocol ConvertUrlRepository {
    
    func convert(urlString: String, completion: @escaping (Result<VideoCode, Error>) -> Void)
    func convert(urlString: String) async throws -> VideoCode
}


// MARK: - Error
public enum ConvertUrlRepositoryError {
    
    case networkError
    case decodingError
    case unknownError
}
