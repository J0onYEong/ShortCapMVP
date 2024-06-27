import Foundation

public protocol ConvertUrlRepository {
    
    func convert(urlString: String, categoryId: String?, completion: @escaping (Result<String, Error>) -> Void)
    func convert(urlString: String, categoryId: String?) async throws -> String
}

// MARK: - Error
public enum ConvertUrlRepositoryError {
    
    case networkError
    case decodingError
    case unknownError
}
