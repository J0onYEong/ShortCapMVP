import Foundation
import Domain

public protocol VideoIdentityStorage {
    
    func save(
        videoIdentity: VideoIdentity,
        completion: @escaping (Result<Bool, Error>) -> Void
    )
    
    func fetch(
        completion: @escaping (Result<[VideoIdentity], Error>) -> Void
    )
}
