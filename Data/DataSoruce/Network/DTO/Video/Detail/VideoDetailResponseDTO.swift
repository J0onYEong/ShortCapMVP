import Foundation
import Domain

struct VideoDetailResponseDTO: Decodable {
    
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
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case keywords
        case url
        case summary
        case address
        case createdAt
        case platform
        case mainCategory
        case mainCategoryId = "mainCategoryIndex"
        case subCategory
        case subCategoryId
        case videoCode = "video_code"
    }
    
    init(
        title: String,
        description: String,
        keywords: [String],
        url: String,
        summary: String,
        address: String,
        createdAt: String,
        platform: String,
        mainCategory: String,
        mainCategoryId: Int,
        subCategory: String,
        subCategoryId: Int,
        videoCode: String
    ) {
        self.title = title
        self.description = description
        self.keywords = keywords
        self.url = url
        self.summary = summary
        self.address = address
        self.createdAt = createdAt
        self.platform = platform
        self.mainCategory = mainCategory
        self.mainCategoryId = mainCategoryId
        self.subCategory = subCategory
        self.subCategoryId = subCategoryId
        self.videoCode = videoCode
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
