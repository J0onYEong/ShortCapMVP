import Foundation
import Domain
import Core

public class DefaultGetVideoSubCategoryRepository: GetVideoSubCategoryRepository {
    
    let networkService: NetworkService
    
    public init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    public func fetch(mainCategory: VideoMainCategory, completion: @escaping (Result<[VideoSubCategory], Error>) -> Void) {
        
        let requestBox = networkService.api.fetchVideoSubCategoriesFor(mainCategoryName: mainCategory.enName)
        
        networkService.network
            .request(requestConvertible: requestBox) { result in
                
                switch result {
                case .success(let dto):
                    
                    completion(.success(dto.data.toEntity()))
                    
                case .failure(let error):
                    
                    completion(.failure(error))
            }
        }
    }
}
