import Foundation

public class VideoSummaryState {
    
    public enum Status: String {
        
        case processing = "PROCESSING"
        case complete = "COMPLETE"
    
    }
    
    public var status: Status
    public var videoId: Int
    
    public init(status: Status, videoId: Int) {
        self.status = status
        self.videoId = videoId
    }
}
