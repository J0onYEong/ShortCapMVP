import Foundation

public protocol GetVideoMainCategoryRepository {
    
    func fetch(completion: @escaping (Result<[VideoMainCategory], Error>) -> Void)
}
