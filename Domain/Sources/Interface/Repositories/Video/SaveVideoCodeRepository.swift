import Foundation

public protocol SaveVideoIdentityRepository {
    
    func save(
        videoIdentity: VideoIdentity,
        completion: @escaping (Bool) -> Void
    )
}
