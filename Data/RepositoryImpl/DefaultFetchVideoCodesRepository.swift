import Foundation
import Domain

public final class DefaultFetchVideoIdentityRepository: FetchVideoIdentityRepository {
    
    let storage: VideoIdentityStorage
    
    public init(videoIdentityStorage storage: VideoIdentityStorage) {
        self.storage = storage
    }
    
    public func fetch(completion: @escaping (Result<[VideoIdentity], Error>) -> Void) {
        
        storage.fetch { result in
            
            switch result {
            case .success(let videoCodes):
                
                completion(.success(videoCodes))
                
            case .failure(let failure):
                
                completion(.failure(failure))
            }
        }
    }
}
