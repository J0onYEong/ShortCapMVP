
public class VideoThumbNailInformation {
    
    public let url: String
    public let size: CGSize
    public let quality: VideoThumbNailQuality
    
    public init(
        url: String,
        size: CGSize,
        quality: VideoThumbNailQuality
    ) {
        self.url = url
        self.size = size
        self.quality = quality
    }
}
