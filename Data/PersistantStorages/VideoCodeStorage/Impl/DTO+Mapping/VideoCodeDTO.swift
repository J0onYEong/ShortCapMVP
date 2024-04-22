import Foundation
import Domain
import CoreData

public struct VideoCodeDTO {
    
    var code: String
    
    func toCoreDataEntity(context: NSManagedObjectContext) -> VideoCodeEntity {
      
        let entity: VideoCodeEntity = .init(context: context)
        
        entity.code = code
        
        return entity
    }
    
    func toDomain() -> VideoCode { VideoCode(code: code) }
}

