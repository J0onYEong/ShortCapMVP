import Foundation

public protocol VideoThumbNailSourceStorage {
    
    func saveUrl(videoCode: String, url: String)
    func fetchUrl(videoCode: String) -> String?
}

public class DefaultVideoThumbNailSourceStorage: VideoThumbNailSourceStorage {
    
    let storage: CoreDataStorage
    
    public init(storage: CoreDataStorage) {
        self.storage = storage
    }
    
    public func saveUrl(videoCode: String, url: String) {
        
        storage.performBackgroundTask { context in
            
            let object = VideoThumbNailEntity(context: context)
            
            object.videoCode = videoCode
            object.sourceUrl = url
            
            try? context.save()
        }
    }
    
    public func fetchUrl(videoCode: String) -> String? {
        
        let fetchRequest = VideoThumbNailEntity.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "videoCode == %@", videoCode)
        
        return try? storage.viewContext.fetch(fetchRequest).first?.sourceUrl
    }
}
