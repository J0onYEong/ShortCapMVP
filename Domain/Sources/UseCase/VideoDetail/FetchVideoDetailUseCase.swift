import Foundation

public protocol FetchVideoDetailUseCase {
    
    func cache(videoCode: String, completion: @escaping (Result<VideoDetail, Error>) -> Void)
    func fetch(videoId: Int, completion: @escaping (Result<VideoDetail, Error>) -> Void)
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
    
    public func cache(videoCode: String, completion: @escaping (Result<VideoDetail, Error>) -> Void) {
        
        videoDetailRepository.fetch(videoCode: videoCode) { result in
            
            switch result {
            case .success(let detail):
                
                guard let detail else { return completion(.failure(FetchVideoDetailUseCaseError.cacheDataNotFound)) }
                
                completion(.success(detail))
                
            case .failure(let error):
                
                #if Device_Debug
                print("‼️로컬에서 디테일 정보 가져오기 실패: \(error.localizedDescription)")
                #endif
                
                completion(.failure(FetchVideoDetailUseCaseError.cacheDataNotFound))
            }
        }
    }
    
    public func fetch(videoId: Int, completion: @escaping (Result<VideoDetail, Error>) -> Void) {
        
        summaryProcessRepository.detail(videoId: videoId) { result in
            
            switch result {
            case .success(let detail):
                
                completion(.success(detail))
                
            case .failure(let error):
                
                #if Device_Debug
                print("‼️네트워크에서 디테일 정보 가져오기 실패: \(error.localizedDescription)")
                #endif
                
                completion(.failure(FetchVideoDetailUseCaseError.failedToFetchDetailFromNetwork))
            }
        }
    }
}

public enum FetchVideoDetailUseCaseError: Error {
    
    case cacheDataNotFound
    case failedToFetchDetailFromNetwork
}
