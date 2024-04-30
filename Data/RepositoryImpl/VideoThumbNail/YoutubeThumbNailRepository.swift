import Domain
import Core

public class YoutubeThumbNailRepository: VideoThumbNailRepository {
    
    let dataTransferService: DataTransferService
    
    public init(dataTransferService: DataTransferService) {
        self.dataTransferService = dataTransferService
    }
    
    public func fetch(videoId: String, screenScale: CGFloat) async throws -> VideoThumbNailInformation {
                
        let endPoint = APIEndpoints.getYoutubeThumbNail(youtubeVideoId: videoId)
        
        let dto = try await dataTransferService.request(with: endPoint)
        
        //                      | 3x        2x
        // low: 120x90          | 40x30     60x45
        // medium: 320x180      | 80x60     160x90v
        // high: 480x360        | 160x120v  240x180
        // standard: 640x480    | 206x160   320x240
        // max: 1280x720        | 420x240   640x360
        //
        // 3x : high / 2x : medium
        
        guard let thumbNails = dto.items?.first?.snippet?.thumbnails else {
                
            throw FetchVideoThumbNailError.dataNotFound(describing: "썸네일 관련 데이터가 없습니다.")
        }
        
        let availableQuality = [
            "default" : thumbNails.default,
            "medium" : thumbNails.medium,
            "high" : thumbNails.high,
            "standard" : thumbNails.standard,
            "maxres" : thumbNails.maxres
        ]
        
        if availableQuality.isEmpty { throw FetchVideoThumbNailError.dataNotFound(describing: "썸네일 관련 데이터가 없습니다.") }
        
        var qualityString = "default"
        
        if screenScale == 3.0 { qualityString = "high" }
        else if screenScale == 2.0 { qualityString = "medium" }
        
        // 목적에 맞는 품질의 썸네일 리턴
        if let highQT = availableQuality[qualityString],
            let url = highQT?.url,
            let height = highQT?.height,
            let width = highQT?.width,
            let quality = VideoThumbNailQuality(rawValue: qualityString) {
            
            return VideoThumbNailInformation(
                url: url,
                size: CGSize(width: Double(width), height: Double(height)),
                quality: quality
            )
        }
        
        // 목적에 맞는 품질이 없는 경우 기본값을 리턴, default가 없는 경우 오류를 throw
        guard let highQT = availableQuality["default"],
              let url = highQT?.url,
              let height = highQT?.height,
              let width = highQT?.width,
              let quality = VideoThumbNailQuality(rawValue: "default") else {
            
            throw FetchVideoThumbNailError.dataNotFound(describing: "")
        }
        
        return VideoThumbNailInformation(
            url: url,
            size: CGSize(width: Double(width), height: Double(height)),
            quality: quality
        )
    }
}

