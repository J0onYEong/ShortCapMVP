import Foundation
import Domain

public class DefaultLocalThumbNailSourceRepository: LocalThumbNailSourceRepository {
    
    let storage: VideoThumbNailSourceStorage
    
    public init(storage: VideoThumbNailSourceStorage) {
        self.storage = storage
    }
    
    public func save(videoCode: String, url: String) {
        
        storage.saveUrl(videoCode: videoCode, url: url)
    }
    
    public func fetch(videoCode: String) -> String? {
        
        storage.fetchUrl(videoCode: videoCode)
    }
}
