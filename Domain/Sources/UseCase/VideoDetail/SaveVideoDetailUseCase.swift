import Foundation

public protocol SaveVideoDetailUseCase {
    
    func save(videoDetail: VideoDetail, completion: @escaping (Bool) -> Void)
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
