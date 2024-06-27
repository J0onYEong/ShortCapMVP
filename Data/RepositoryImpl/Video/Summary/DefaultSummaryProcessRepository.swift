import Foundation
import Domain
import Core

public class DefaultSummaryProcessRepository: SummaryProcessRepository {
    
    let networkService: NetworkService
    
    public init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    public func state(videoCode: String, completion: @escaping ((Result<VideoSummaryState, Error>) -> Void)) {
        
        let requestConvertible = networkService.api.fetchVideoSummaryState(videoCode: videoCode)
        
        networkService.network.request(requestConvertible: requestConvertible) { result in
            
            switch result {
            case .success(let responseDTO):
                
                let videoState = responseDTO.data.toDomain()
                
                return completion(.success(videoState))
                                                                               
            case .failure(let failure):
                
                completion(.failure(failure))
            }
        }
    }
}
