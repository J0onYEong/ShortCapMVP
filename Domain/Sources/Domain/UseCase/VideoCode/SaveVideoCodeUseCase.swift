import Foundation

public protocol SaveVideoCodeUseCase {
    
    func execute(
        videoCode: VideoCode,
        completion: @escaping (VideoCode?) -> Void
    )
}

public protocol FetchVideoCodeUseCase {
    
    func fetch(
        url: String,
        cached: @escaping (VideoCode) -> Void
    )
}

public final class DefaultSaveVideoCodeUseCase: SaveVideoCodeUseCase {
    
    let videoCodeRepository: VideoCodeRepository
    
    public func execute(videoCode: VideoCode, completion: @escaping (VideoCode?) -> Void) {
        
        videoCodeRepository.save(
            videoCode: videoCode,
            completion: completion
        )
    }
    
    init(videoCodeRepository: VideoCodeRepository) {
        self.videoCodeRepository = videoCodeRepository
    }
}
