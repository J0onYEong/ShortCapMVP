import Foundation
import Domain

public class DefaultGetMainVideoCategoryRepository: GetVideoMainCategoryRepository {
    
    public init() { }
    
    public func fetch(completion: @escaping (Result<[VideoMainCategory], Error>) -> Void) {
        var categories = JSONFiles.items.map { item in
            let enName = item["enName"] as! String
            let korName =  item["korName"] as! String
            let index = item["index"] as! Int
            
            return VideoMainCategory(korName: korName, enName: enName, categoryId: index)
        }
        
        // '전체' 메인카테고리 추가
        categories.insert(.all, at: 0)
        
        completion(.success(categories))
    }
}
