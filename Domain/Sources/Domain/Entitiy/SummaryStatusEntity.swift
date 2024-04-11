import Foundation

public class SummaryStatusEntity {
    
    public enum Status: String {
        
        case processing
        case complete
        
        public static func status(_ str: String) -> Self {
            
            switch str {
                
            case "PROCESSING":
                return .processing
            case "COMPLETE":
                return .complete
            default:
                fatalError()
            }
        }
    }
    
    public var status: Status
    public var videoId: Int
    
    public init(status: Status, videoId: Int) {
        self.status = status
        self.videoId = videoId
    }
}
