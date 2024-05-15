import Foundation
import Domain
import Core

public class DefaultGetVideoSubCategoryRepository: GetVideoSubCategoryRepository {
    
    let service: DataTransferService
    
    public init(dataTransferService service: DataTransferService) {
        self.service = service
    }
    
    public func fetch(mainCategory: VideoMainCategory, completion: @escaping (Result<[VideoSubCategory], GetVideoSubCategoryRepositoryError>) -> Void) {
        
        let endPoint = APIEndpoints.getVideoSubCategories(mainCategory: mainCategory.enName)
        
        service.request(with: endPoint) { result in
            
            switch result {
            case .success(let dto):
                
                completion(.success(dto.toEntity()))
                
            case .failure(let error):
                
                switch error {
                case .networkFailure(_):
                    completion(.failure(.networkError))
                default:
                    printIfDebug("‼️서브카테고리 가져오기 실패: \(error.localizedDescription)")
                    completion(.failure(.unknownError))
                }
            }
        }
    }
}
