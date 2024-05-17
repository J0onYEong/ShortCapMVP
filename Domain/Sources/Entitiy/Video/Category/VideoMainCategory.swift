import Foundation

public class VideoMainCategory {
    
    public let korName: String
    public let enName: String
    public let categoryId: Int
    
    public init(korName: String, enName: String, categoryId: Int) {
        self.korName = korName
        self.enName = enName
        self.categoryId = categoryId
    }
    
    public static let all = VideoMainCategory(korName: "전체", enName: "ALL", categoryId: 100)
}

extension VideoMainCategory: Equatable {
    
    public static func == (lhs: VideoMainCategory, rhs: VideoMainCategory) -> Bool {
        lhs.categoryId == rhs.categoryId
    }
}
