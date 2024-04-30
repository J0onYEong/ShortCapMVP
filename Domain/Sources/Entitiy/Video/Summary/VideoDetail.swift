import Foundation

public class VideoDetail {
    
    public var title: String
    public var description: String
    public var keywords: [String]
    public var url: String
    public var summary: String
    public var address: String
    public var createdAt: String
    public var platform: VideoPlatform
    public var mainCategory: String
    public var videoCode: String
    
    public init(
        title: String,
        description: String,
        keywords: [String],
        url: String,
        summary: String,
        address: String,
        createdAt: String,
        platform: VideoPlatform,
        mainCategory: String,
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
        self.videoCode = videoCode
    }
    
    public static let mock: VideoDetail = .init(
        title: "서버오류",
        description: "서버오류",
        keywords: [],
        url: "서버오류",
        summary: "서버오류",
        address: "서버오류",
        createdAt: "",
        platform: .youtube,
        mainCategory: "서버오류",
        videoCode: ""
    )
}
