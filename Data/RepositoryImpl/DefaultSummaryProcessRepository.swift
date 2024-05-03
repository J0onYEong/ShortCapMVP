import Foundation
import Domain
import Core

public class DefaultSummaryProcessRepository: SummaryProcessRepository {
    
    let dataTransferService: DataTransferService
    
    public init(dataTransferService: DataTransferService) {
        self.dataTransferService = dataTransferService
    }
    
    public func state(videoCode: String, completion: @escaping ((Result<VideoSummaryState, Error>) -> Void)) {
        
        let endPoint = APIEndpoints.getVideoSummaryState(with: videoCode)
        
        dataTransferService.request(with: endPoint, on: DispatchQueue.global()) { result in
            
            switch result {
            case .success(let responseDTO):
                
                if let videoState = responseDTO.data?.toDomain() {
                    
                    return completion(.success(videoState))
                }
                
                completion(.failure(SummaryProcessError.unknownError))
                                                                               
            case .failure(let failure):
                
                completion(.failure(failure))
            }
        }
    }
    
    public func detail(videoId: Int, completion: @escaping ((Result<VideoDetail, Error>) -> Void)) {
        
        let endPoint = APIEndpoints.getVideoDetail(with: videoId)
        
        dataTransferService.request(with: endPoint) { result in
            
            switch result {
            case .success(let responseDTO):
                
                if let videoDetail = responseDTO.data?.toDomain() {
                    
                    return completion(.success(videoDetail))
                }
                
                completion(.failure(SummaryProcessError.unknownError))
                                                                               
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
}
