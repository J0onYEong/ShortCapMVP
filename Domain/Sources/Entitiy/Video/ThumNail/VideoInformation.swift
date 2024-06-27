
public class VideoInformation {
    
    public let identifier: String
    public let platform: VideoPlatform
    
    public init(identifier: String, platform: VideoPlatform) {
        self.identifier = identifier
        self.platform = platform
    }
}
