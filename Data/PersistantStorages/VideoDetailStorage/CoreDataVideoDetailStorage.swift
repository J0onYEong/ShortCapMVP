import Foundation

public enum CoreDataVideoDetailStorageError: Error {
    
    case duplicateError
}

public class CoreDataVideoDetailStorage: VideoDetailStorage {
    
    let coreDataStorage: CoreDataStorage
    
    public init(coreDataStorage: CoreDataStorage) {
        self.coreDataStorage = coreDataStorage
    }
    
    public func save(detail: VideoDetailDTO, completion: @escaping (Result<VideoDetailDTO, Error>) -> Void) {
        
        coreDataStorage.performBackgroundTask { context in
            
            do {
                
                let detailObject = detail.toCoreDataEntity(context: context)
                
                try context.save()
                
                completion(.success(detail))
                
            } catch {
                
                completion(.failure(error))
            }
        }
    }
    
    public func fetch(videoCode: String, completion: @escaping (Result<VideoDetailDTO?, Error>) -> Void) {
        
        coreDataStorage.performBackgroundTask { context in
            
            let fetchRequest = VideoDetailEntity.fetchRequest()
            
            fetchRequest.predicate = NSPredicate(format: "videoCode == %@", "\(videoCode)")
            
            do {
                let object = try context.fetch(fetchRequest)
                
                guard let detailDto = object.first?.toDTO() else { return completion(.success(nil)) }
                
                completion(.success(detailDto))
            } catch {
                
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }
}
