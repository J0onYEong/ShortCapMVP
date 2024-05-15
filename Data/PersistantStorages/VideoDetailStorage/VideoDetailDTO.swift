import Foundation
import CoreData
import Domain

public struct VideoDetailDTO {
    
    public var title: String
    public var description: String
    public var keywords: [String]
    public var url: String
    public var summary: String
    public var address: String
    public var createdAt: String
    public var platform: String
    public var mainCategory: String
    public var mainCategoryId: Int
    public var subCategory: String
    public var subCategoryId: Int
    public var videoCode: String
    
    func toCoreDataEntity(context: NSManagedObjectContext) -> VideoDetailEntity {
      
        let object = VideoDetailEntity(context: context)
        
        object.title = title
        object.des = description
        object.keywords = keywords.reduce("", { $0 + ",\($1)" })
        object.url = url
        object.summary = summary
        object.address = address
        object.createdAt = createdAt
        object.platform = platform
        object.mainCategory = mainCategory
        object.mainCategoryId = Int16(mainCategoryId)
        object.subCategory = subCategory
        object.subCategoryId = Int16(subCategoryId)
        object.videoCode = videoCode
        
        return object
    }
    
    func toDomain() -> VideoDetail {
        VideoDetail(
            title: title,
            description: description,
            keywords: keywords,
            url: url,
            summary: summary,
            address: address,
            createdAt: createdAt,
            platform: VideoPlatform(rawValue: platform) ?? .unknown,
            mainCategory: mainCategory,
            mainCategoryId: mainCategoryId,
            subCategory: subCategory,
            subCategoryId: subCategoryId,
            videoCode: videoCode
        )
    }
}

