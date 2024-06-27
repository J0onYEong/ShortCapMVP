import Foundation
import Domain
import Core

public class DefaultGetVideoSubCategoryRepository: GetVideoSubCategoryRepository {
    
    let networkWithShortcap: NetworkWithShortcap
    
    init(networkWithShortcap: NetworkWithShortcap) {
        self.networkWithShortcap = networkWithShortcap
    }
    
    public func fetch(mainCategory: VideoMainCategory, completion: @escaping (Result<[VideoSubCategory], Error>) -> Void) {
        
        let requestBox = networkWithShortcap.api.fetchVideoSubCategoriesFor(mainCategoryName: mainCategory.enName)
        
        networkWithShortcap.network
            .request(requestConvertible: requestBox) { result in
                
                switch result {
                case .success(let dto):
                    
                    if let subCategories = dto.data?.toEntity() {
                        
                        completion(.success(subCategories))
                    }
                    
                    completion(.failure(ResponseError.dataIsNotFound))
                    
                case .failure(let error):
                    
                    completion(.failure(error))
            }
        }
    }
}
