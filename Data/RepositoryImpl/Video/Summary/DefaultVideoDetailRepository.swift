import Foundation
import Domain
import Core

public final class DefaultVideoDetailRepository: VideoDetailLocalRepository {
    
    let storage: VideoDetailStorage
    
    public init(storage: VideoDetailStorage) {
        self.storage = storage
    }
    
    public func save(
        detail: VideoDetail,
        completion: @escaping (Bool) -> Void) {
        
        let detailDto = VideoDetailDTO(
            title: detail.title,
            description: detail.description,
            keywords: detail.keywords,
            url: detail.url,
            summary: detail.summary,
            address: detail.address,
            createdAt: detail.createdAt,
            platform: detail.platform.rawValue,
            mainCategory: detail.mainCategory,
            mainCategoryId: detail.mainCategoryId,
            subCategory: detail.mainCategory,
            subCategoryId: detail.mainCategoryId,
            videoCode: detail.videoCode
        )
            
        storage.save(detail: detailDto) { result in
            
            switch result {
            case .success(_):
                
                completion(true)
            case .failure(_):
                
                completion(false)
            }
        }
    }
    
    public func fetch(videoCode: String, completion: @escaping (Result<VideoDetail?, Error>) -> Void) {
        
        storage.fetch(videoCode: videoCode) { result in
            
            switch result {
            case .success(let detailDTO):
                
                completion(.success(detailDTO?.toDomain()))
                
            case .failure(let error):
                
                completion(.failure(error))
            }
        }
    }
}
