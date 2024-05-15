import Foundation

public protocol GetVideoSubCategoryRepository {
    
    func fetch(
        mainCategory: VideoMainCategory,
        completion: @escaping (Result<[VideoSubCategory], GetVideoSubCategoryRepositoryError>) -> Void
    )
}

public enum GetVideoSubCategoryRepositoryError: Error {
    
    case networkError
    case unknownError
}
