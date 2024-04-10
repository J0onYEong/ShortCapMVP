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
    public var videoCode: Int
    
    public init(status: Status, videoCode: Int) {
        self.status = status
        self.videoCode = videoCode
    }
}
