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
}
