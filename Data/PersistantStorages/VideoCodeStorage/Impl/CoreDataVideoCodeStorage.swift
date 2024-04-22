import Foundation

public final class CoreDataVideoCodeStorage: VideoCodeStorage {
    
    private let coreDataStorage: CoreDataStorage

    public init(coreDataStorage: CoreDataStorage = .shared) {
        self.coreDataStorage = coreDataStorage
    }
    
    public func save(videoCodeDTO: VideoCodeDTO, completion: @escaping (Result<VideoCodeDTO, Error>) -> Void) {
        
        coreDataStorage.performBackgroundTask { context in
            
            do {
                let _ = videoCodeDTO.toCoreDataEntity(context: context)
                
                try context.save()
                
                completion(.success(videoCodeDTO))
                
            } catch {
                
                completion(.failure(CoreDataStorageError.saveError(error)))
            }
        }
    }
    
    public func getResponse(completion: @escaping (Result<[VideoCodeDTO], Error>) -> Void) {
        
        coreDataStorage.performBackgroundTask { context in
            
            let fetchRequest = VideoCodeEntity.fetchRequest()
            
            do {
                
                let objects = try context.fetch(fetchRequest)
                
                let mapped = objects.compactMap { $0.code }.map { VideoCodeDTO(code: $0) }
                
                completion(.success(mapped))
                
            } catch {
                
                completion(.failure(CoreDataStorageError.readError(error)))
            }
        }
    }
}
