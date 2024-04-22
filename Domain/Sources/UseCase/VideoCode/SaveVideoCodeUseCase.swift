import Foundation

public protocol SaveVideoCodeUseCase {
    
    func execute(
        videoCode: VideoCode,
        completion: @escaping (VideoCode?) -> Void
    )
}

public final class DefaultSaveVideoCodeUseCase: SaveVideoCodeUseCase {
    
    let saveVideoCodeRepository: SaveVideoCodeRepository
    
    public func execute(videoCode: VideoCode, completion: @escaping (VideoCode?) -> Void) {
        
        saveVideoCodeRepository.save(
            videoCode: videoCode,
            completion: completion
        )
    }
    
    public init(saveVideoCodeRepository: SaveVideoCodeRepository) {
        self.saveVideoCodeRepository = saveVideoCodeRepository
    }
}
