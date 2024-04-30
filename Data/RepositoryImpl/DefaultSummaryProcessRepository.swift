import Foundation
import Domain
import Core

public class DefaultSummaryProcessRepository: SummaryProcessRepository {
    
    let dataTransferService: DataTransferService
    
    public init(dataTransferService: DataTransferService) {
        self.dataTransferService = dataTransferService
    }
    
    private func checkServerMessage<T>(_ response: ResponseDTOWrapper<T>) throws where T: Decodable {
        
        if response.result == "error" {
            
            throw SummaryProcessError.serverMessageError(message: response.message ?? "no message")
        }
    }
    
    public func state(videoCode: VideoCode, completion: @escaping ((Result<VideoSummaryState, Error>) -> Void)) {
        
        let endPoint = APIEndpoints.getVideoSummaryState(with: videoCode.code)
        
        dataTransferService.request(with: endPoint, on: DispatchQueue.global()) { result in
            
            switch result {
            case .success(let responseDTO):
                
                do {
                    try self.checkServerMessage(responseDTO)
                    
                    completion(.success(responseDTO.data?.toDomain() ?? .init(status: .processing, videoId: -1)))
                    
                } catch { completion(.failure(error)) }
                                                                               
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
                
                do {
                    try self.checkServerMessage(responseDTO)
                    
                    completion(.success(responseDTO.data?.toDomain() ?? VideoDetail.mock))
                    
                } catch { completion(.failure(error)) }
                                                                               
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
}
