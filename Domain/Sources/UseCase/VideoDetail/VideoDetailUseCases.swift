import Foundation

public protocol CheckSummaryStateUseCase {
    
    func check(videoCode: String, completion: @escaping ((Result<VideoSummaryState, Error>) -> Void))
}

public protocol FetchVideoDetailUseCase {
    
    func cache(videoCode: String, completion: @escaping (Result<VideoDetail?, Error>) -> Void)
    func fetch(videoId: Int, completion: @escaping (Result<VideoDetail, Error>) -> Void)
}

public protocol SaveVideoDetailUseCase {
    
    func save(videoDetail: VideoDetail, completion: @escaping (Bool) -> Void)
}


// MARK: - Impl

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


public final class DefaultFetchVideoDetailUseCase: FetchVideoDetailUseCase {
    
    private let videoDetailRepository: VideoDetailLocalRepository
    private let summaryProcessRepository: SummaryProcessRepository
    
    public init(
        videoDetailRepository: VideoDetailLocalRepository,
        summaryProcessRepository: SummaryProcessRepository
    ) {
        self.videoDetailRepository = videoDetailRepository
        self.summaryProcessRepository = summaryProcessRepository
    }
    
    public func cache(videoCode: String, completion: @escaping (Result<VideoDetail?, Error>) -> Void) {
        
        videoDetailRepository.fetch(videoCode: videoCode, completion: completion)
    }
    
    public func fetch(videoId: Int, completion: @escaping (Result<VideoDetail, Error>) -> Void) {
        
        summaryProcessRepository.detail(videoId: videoId, completion: completion)
    }
}

public final class DefaultSaveVideoDetailUseCase: SaveVideoDetailUseCase {
    
    private let videoDetailRepository: VideoDetailLocalRepository
    
    public init(videoDetailRepository: VideoDetailLocalRepository) {
        self.videoDetailRepository = videoDetailRepository
    }
    
    public func save(videoDetail: VideoDetail, completion: @escaping (Bool) -> Void) {
        
        videoDetailRepository.save(detail: videoDetail, completion: completion)
    }
}
