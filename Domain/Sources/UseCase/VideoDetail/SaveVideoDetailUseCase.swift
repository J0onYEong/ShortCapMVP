import Foundation

public protocol SaveVideoDetailUseCase {
    
    func save(videoDetail: VideoDetail)
}

public final class DefaultSaveVideoDetailUseCase: SaveVideoDetailUseCase {
    
    private let videoDetailRepository: VideoDetailLocalRepository
    
    public init(videoDetailRepository: VideoDetailLocalRepository) {
        self.videoDetailRepository = videoDetailRepository
    }
    
    public func save(videoDetail: VideoDetail) {
        
        videoDetailRepository.save(detail: videoDetail) { isSuccess in
            
            #if Device_Debug || Local_DEbug
            print(isSuccess ? "✅ 비디오 디테일 저장성공: \(videoDetail.videoCode)" : "비디오 디테일 저장실패 \(videoDetail.videoCode)")
            #endif
        }
    }
}
