import Foundation

public protocol CheckSummaryStateUseCase {
    
    func check(videoCode: String, completion: @escaping ((Result<VideoSummaryState, Error>) -> Void))
}

public final class DefaultCheckSummaryStateUseCase: CheckSummaryStateUseCase {
    
    private let summaryProcessRepository: SummaryProcessRepository
    
    public init(summaryProcessRepository: SummaryProcessRepository) {
        self.summaryProcessRepository = summaryProcessRepository
    }
    
    public func check(videoCode: String, completion: @escaping ((Result<VideoSummaryState, Error>) -> Void)) {
        
        summaryProcessRepository.state(videoCode: videoCode) { result in
            
            switch result {
            case .success(let state):
                
                completion(.success(state))
            case .failure(let error):
                
                completion(.failure(error))
            }
        }
    }
}
