import Foundation

public protocol SaveVideoCodeUseCase {
    
    func execute(
        videoCode: String,
        completion: @escaping (String?) -> Void
    )
}

public final class DefaultSaveVideoCodeUseCase: SaveVideoCodeUseCase {
    
    let saveVideoCodeRepository: SaveVideoCodeRepository
    
    public func execute(videoCode: String, completion: @escaping (String?) -> Void) {
        
        saveVideoCodeRepository.save(
            videoCode: videoCode,
            completion: completion
        )
    }
    
    public init(saveVideoCodeRepository: SaveVideoCodeRepository) {
        self.saveVideoCodeRepository = saveVideoCodeRepository
    }
}
