import Foundation

public protocol SaveVideoIndentityUserCase {
    
    func execute(
        videoIdentity: VideoIdentity,
        completion: @escaping (Bool) -> Void
    )
}

public final class DefualtSaveVideoIndentityUseCase: SaveVideoIndentityUserCase {
    
    let repository: SaveVideoIdentityRepository
    
    public init(saveVideoIdentityRepository repository: SaveVideoIdentityRepository) {
        self.repository = repository
    }
    
    public func execute(videoIdentity: VideoIdentity, completion: @escaping (Bool) -> Void) {
        
        repository.save(
            videoIdentity: videoIdentity,
            completion: completion
        )
    }
}
