import Foundation
import Domain

public final class DefaultFetchVideoCodesRepository: FetchVideoCodesRepository {
    
    let storage: VideoCodeStorage
    
    public init(storage: VideoCodeStorage) {
        self.storage = storage
    }
    
    public func fetch(completion: @escaping (Result<[VideoCode], Error>) -> Void) {
        
        storage.getResponse { result in
            
            switch result {
            case .success(let videoCodes):
                
                completion(.success(videoCodes.map { $0.toDomain() }))
                
            case .failure(let failure):
                
                completion(.failure(failure))
            }
        }
    }
}
