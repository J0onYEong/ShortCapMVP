import Foundation

public protocol VideoDetailUseCase {
    
    func getDetail(videoCode: VideoCode, completion: @escaping (Result<VideoDetail, Error>) -> Void)
    func getDetailFromLocal(videoCode: VideoCode, completion: @escaping (Result<VideoDetail, Error>) -> Void)
    func saveDetail(videoCode: VideoCode, videoDetail: VideoDetail, completion: @escaping (Result<VideoDetail, Error>) -> Void)
}

public final class DefaultVideoDetailUseCase: VideoDetailUseCase {
    
    let summaryProcessRepository: SummaryProcessRepository
    let videoDetailRepository: VideoDetailRepository
    
    public init(
        summaryProcessRepository: SummaryProcessRepository,
        videoDetailRepository: VideoDetailRepository
    ) {
        self.summaryProcessRepository = summaryProcessRepository
        self.videoDetailRepository = videoDetailRepository
    }
    
    /// 로컬저장소로부터 디테일 정보를 가져옵니다.
    public func getDetailFromLocal(videoCode: VideoCode, completion: @escaping (Result<VideoDetail, Error>) -> Void) {
        
        videoDetailRepository.fetch(videoCode: videoCode, completion: completion)
    }

    /// 요약상태 확인후 네트워크로부터 디테일 정보를 가져옵니다.
    public func getDetail(videoCode: VideoCode, completion: @escaping (Result<VideoDetail, Error>) -> Void) {
        
        summaryProcessRepository.state(videoCode: videoCode) { result in
            
            switch result {
            case .success(let state):
                
                if state.status == .complete {
                    
                    // 요약완료, 비디오 디테일 요청
                    self.summaryProcessRepository.detail(videoId: state.videoId) { result in
                        
                        switch result {
                        case .success(let detail):
                            
                            completion(.success(detail))
                            
                            // 획득한 디테일을 로컬에 저장
                            self.saveDetail(videoCode: videoCode, videoDetail: detail) { _ in }
                            
                        case .failure(let failure):
                            
                            completion(.failure(failure))
                        }
                    }
                } else {
                    
                    completion(.failure(FetchVideoDetailError.videoIsProcessing))
                }
                
            case .failure(let failure):
                
                completion(.failure(failure))
            }
        }
    }
    
    /// 비디오 디테일을 저장
    public func saveDetail(videoCode: VideoCode, videoDetail: VideoDetail, completion: @escaping (Result<VideoDetail, Error>) -> Void) {
        
        videoDetailRepository.save(
            videoCode: videoCode,
            detail: videoDetail,
            completion: completion)
    }
}


// MARK: - Fetch Error
public enum FetchVideoDetailError: Error {
    
    case videoIsProcessing
}
