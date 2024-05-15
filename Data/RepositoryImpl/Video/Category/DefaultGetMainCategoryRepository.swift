import Foundation
import Domain

public class DefaultGetMainVideoCategoryRepository: GetVideoMainCategoryRepository {
    
    public func fetch(completion: @escaping (Result<[VideoMainCategory], Error>) -> Void) {
        let categories = JSONFiles.items.map { item in
            let enName = item["enName"] as! String
            let korName =  item["korName"] as! String
            let index = item["index"] as! Int
            
            return VideoMainCategory(korName: korName, enName: enName, categoryId: index)
        }
        
        completion(.success(categories))
    }
}
