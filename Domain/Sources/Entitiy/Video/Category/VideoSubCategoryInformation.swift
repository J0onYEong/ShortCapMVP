import Foundation

public class VideoSubCategoryMappingResult {
    
    public enum State { case complete, processing }
    
    public var count: Int
    public var creationDate: Date
    public private(set) var state: State
    
    public static let processing: VideoSubCategoryMappingResult = .init(count: -1, creationDate: .now, state: .processing)
    
    private static let dateFormatter = ISO8601DateFormatter()
    
    public init(count: Int, creationDate: Date, state: State = .complete) {
        self.count = count
        self.creationDate = creationDate
        self.state = state
    }
    
    public convenience init(count: Int, creationDateString: String) {
        
        let date = Self.dateFormatter.date(from: creationDateString)
        
        self.init(count: count, creationDate: date ?? .now)
    }
}
