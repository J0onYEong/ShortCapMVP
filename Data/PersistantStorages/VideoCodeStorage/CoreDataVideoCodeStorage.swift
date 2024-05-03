import Foundation

public final class CoreDataVideoCodeStorage: VideoCodeStorage {
    
    private let coreDataStorage: CoreDataStorage

    public init(coreDataStorage: CoreDataStorage = .shared) {
        self.coreDataStorage = coreDataStorage
    }
    
    public func save(videoCode: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        coreDataStorage.performBackgroundTask { context in
            
            do {
                
                let entity = VideoCodeEntity(context: context)
                
                entity.videoCode = videoCode
                
                try context.save()
                
                completion(.success(videoCode))
                
            } catch {
                
                completion(.failure(CoreDataStorageError.saveError(error)))
            }
        }
    }
    
    public func fetch(completion: @escaping (Result<[String], Error>) -> Void) {
        
        coreDataStorage.performBackgroundTask { context in
            
            let fetchRequest = VideoCodeEntity.fetchRequest()
            
            do {
                
                let objects = try context.fetch(fetchRequest)
                
                let mapped = objects.compactMap { $0.videoCode }
                
                completion(.success(mapped))
                
            } catch {
                
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }
}
