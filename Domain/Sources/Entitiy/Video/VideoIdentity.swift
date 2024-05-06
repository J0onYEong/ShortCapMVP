import Foundation

public class VideoIdentity: Hashable, Equatable {

    public let videoCode: String
    public let originUrl: String
    
    public init(videoCode: String, originUrl: String) {
        self.videoCode = videoCode
        self.originUrl = originUrl
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(videoCode)
    }
    
    public static func == (lhs: VideoIdentity, rhs: VideoIdentity) -> Bool {
        lhs.videoCode == rhs.videoCode
    }
}
