import Foundation

public class CoreDataVideoDetailStorage: VideoDetailStorage {
    
    let coreDataStorage: CoreDataStorage
    
    public init(coreDataStorage: CoreDataStorage = .shared) {
        self.coreDataStorage = coreDataStorage
    }
    
    public func save(
        videoCode: VideoCodeDTO,
        detail: VideoDetailDTO,
        completion: @escaping (Result<VideoDetailDTO, Error>) -> Void) {
        
        coreDataStorage.performBackgroundTask { context in
            
            let detailObject = detail.toCoreDataEntity(context: context)
            
            let fetchRequest = VideoCodeEntity.fetchRequest()
            
            fetchRequest.predicate = NSPredicate(format: "code == %@", "\(videoCode.code)")
            
            do {
                
                let objects = try context.fetch(fetchRequest)
                
                if let object = objects.first {
                    
                    object.summaryDetailEntity = detailObject
                } else {
                    
                    let videoCodeObject = videoCode.toCoreDataEntity(context: context)
                    
                    videoCodeObject.summaryDetailEntity = detailObject
                }
                
                try context.save()
                
                completion(.success(detail))
                
            } catch {
                
                completion(.failure(error))
            }
        }
    }
    
    public func fetch(videoCode: VideoCodeDTO, completion: @escaping (Result<VideoDetailDTO?, Error>) -> Void) {
        
        coreDataStorage.performBackgroundTask { context in
            
            let fetchRequest = VideoCodeEntity.fetchRequest()
            
            fetchRequest.predicate = NSPredicate(format: "code == %@", "\(videoCode.code)")
            
            do {
                let object = try context.fetch(fetchRequest)
                
                guard let detailEntity = object.first?.summaryDetailEntity else { return completion(.success(nil)) }
                
                let detailDto = detailEntity.toDTO()
                
                completion(.success(detailDto))
            } catch {
                
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }
}
