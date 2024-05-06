import Foundation
import Domain

public final class CoreDataVideoIdentityStorage: VideoIdentityStorage {
    
    private let storage: CoreDataStorage

    public init(coreDataStorage storage: CoreDataStorage) {
        self.storage = storage
    }
    
    public func save(videoIdentity identity: VideoIdentity, completion: @escaping (Result<Bool, Error>) -> Void) {
        
        storage.performBackgroundTask { context in
            
            do {
                
                let entity = VideoIdentityEntity(context: context)
                
                entity.videoCode = identity.videoCode
                entity.originUrl = identity.originUrl
                
                try context.save()
                
                completion(.success(true))
                
            } catch {
                
                completion(.failure(CoreDataStorageError.saveError(error)))
            }
        }
    }
    
    public func fetch(completion: @escaping (Result<[VideoIdentity], Error>) -> Void) {
        
        storage.performBackgroundTask { context in
            
            let fetchRequest = VideoIdentityEntity.fetchRequest()
            
            do {
                
                let objects = try context.fetch(fetchRequest)
                
                let mapped = objects.compactMap { VideoIdentity(videoCode: $0.videoCode!, originUrl: $0.originUrl!) }
                
                completion(.success(mapped))
                
            } catch {
                
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }
}
