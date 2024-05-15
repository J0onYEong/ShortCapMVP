import Foundation

public protocol FetchVideoIdentityRepository {
    
    func fetch(completion: @escaping (Result<[VideoIdentity], Error>) -> Void)
}
