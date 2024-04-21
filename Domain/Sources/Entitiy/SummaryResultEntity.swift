import Foundation

public class SummaryResultEntity {
    
    public var title: String
    public var description: String
    public var keywords: [String]
    public var url: String
    public var summary: String
    public var address: String
    public var createdAt: String
    public var platform: String
    public var mainCategory: String
    public var videoCode: String
    public var isFetched: Bool
    
    public init(title: String, description: String, keywords: [String], url: String, summary: String, address: String, createdAt: String, platform: String, mainCategory: String, videoCode: String, isFetched: Bool) {
        self.title = title
        self.description = description
        self.keywords = keywords
        self.url = url
        self.summary = summary
        self.address = address
        self.createdAt = createdAt
        self.platform = platform
        self.mainCategory = mainCategory
        self.videoCode = videoCode
        self.isFetched = isFetched
    }
    
    public init(videoCode: String) {
        
        self.title = ""
        self.description = ""
        self.keywords = []
        self.url = ""
        self.summary = ""
        self.address = ""
        self.createdAt = ""
        self.platform = ""
        self.mainCategory = ""
        self.videoCode = videoCode
        self.isFetched = false
    }
}
