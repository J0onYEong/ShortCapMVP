import Foundation

public class VideoSubCategoryInformation {
    
    public let count: Int
    public let creationDate: Date
    
    private static let dateFormatter = ISO8601DateFormatter()
    
    public init(count: Int, creationDate: Date) {
        self.count = count
        self.creationDate = creationDate
    }
    
    public convenience init(count: Int, creationDateString: String) {
        
        let date = Self.dateFormatter.date(from: creationDateString)
        
        self.init(count: count, creationDate: date ?? .now)
    }
}
