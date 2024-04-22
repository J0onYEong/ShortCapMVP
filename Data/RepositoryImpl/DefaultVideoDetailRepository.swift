import Foundation
import Domain

public final class DefaultVideoDetailRepository: VideoDetailRepository {
    
    let storage: VideoDetailStorage
    
    public init(storage: VideoDetailStorage) {
        self.storage = storage
    }
    
    public func save(
        videoCode: VideoCode,
        detail: VideoDetail,
        completion: @escaping (Result<Domain.VideoDetail, Error>) -> Void) {
        
        let detailDto = VideoDetailDTO(
            title: detail.title,
            description: detail.description,
            keywords: detail.keywords,
            url: detail.url,
            summary: detail.summary,
            address: detail.address,
            createdAt: detail.createdAt,
            platform: detail.platform,
            mainCategory: detail.mainCategory,
            videoCode: detail.videoCode
        )
        
        let codeDto = VideoCodeDTO(code: videoCode.code)
            
        storage.save(
            videoCode: codeDto,
            detail: detailDto) { result in
            
            switch result {
            case .success(let dto):
                
                completion(.success(dto.toDomain()))
            case .failure(let failure):
                
                completion(.failure(failure))
            }
        }
    }
    
    public func fetch(videoCode: VideoCode, completion: @escaping (Result<VideoDetail, Error>) -> Void) {
        
        storage.fetch(videoCode: VideoCodeDTO(code: videoCode.code)) { result in
            
            switch result {
            case .success(let detailDTO):
                if let dto = detailDTO {
                    
                    completion(.success(dto.toDomain()))
                } else {
                    
                    completion(.failure(FetchVideoDetailFromLocalError.dataNotFound))
                }
                
            case .failure(let failure):
                
                completion(.failure(failure))
            }
        }
    }
}

public enum FetchVideoDetailFromLocalError: Error {
    
    case dataNotFound
}
