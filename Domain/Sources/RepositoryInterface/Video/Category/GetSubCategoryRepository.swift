import Foundation

public protocol GetVideoSubCategoryRepository {
    
    func fetch(
        mainCategory: VideoMainCategory,
        completion: @escaping (Result<[VideoSubCategory], Error>) -> Void
    )
}
