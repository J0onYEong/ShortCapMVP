
/// 화면에 표시할 비디오 정보를 서버로 부터 가져올 때 사용하는 엔티티입니다.
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
    
    public static let mock: VideoThumbNailInformation =  .init(
        url: "https://dummyimage.com/150x200/000/fff",
        size: CGSize(width: 150, height: 200),
        quality: .default
    )
}
