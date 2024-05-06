import Foundation

public protocol FetchVideoIdentityUseCase {
    
    func execute(completion: @escaping (Result<[VideoIdentity], Error>) -> Void)
}

public final class DefaultFetchVideoIdentityUseCase: FetchVideoIdentityUseCase {
    
    let repository: FetchVideoIdentityRepository
    
    public init(fetchVideoIdentityRepository repository: FetchVideoIdentityRepository) {
        
        self.repository = repository
    }
    
    public func execute(completion: @escaping (Result<[VideoIdentity], Error>) -> Void) {
        
        repository.fetch(completion: completion)
    }
}
