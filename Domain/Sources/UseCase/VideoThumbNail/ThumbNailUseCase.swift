import Foundation

public protocol VideoThumbNailUseCase {
    
    func fetch(videoInfo: VideoInformation, screenScale: CGFloat) async throws -> VideoThumbNailInformation
    func fetchFromLocal(videoCode: String) -> String?
    func save(videoCode: String, url: String)
}

public class DefaultVideoThumbNailUseCase: VideoThumbNailUseCase {
    
    private let youtubeRepository: FetchThumbNailRepository
    
    private let localRepository: LocalThumbNailSourceRepository
    
    public init(youtubeRepository: FetchThumbNailRepository, localRepository: LocalThumbNailSourceRepository) {
        self.youtubeRepository = youtubeRepository
        self.localRepository = localRepository
    }
    
    public func fetch(videoInfo: VideoInformation, screenScale: CGFloat) async throws -> VideoThumbNailInformation {
        
        switch videoInfo.platform {
        case .youtube:
            
            let videoUrl = videoInfo.url
            
            guard let videoId = extractYouTubeID(target: videoUrl) else { fatalError() }
            
            return try await youtubeRepository.fetch(videoIdForPlatform: videoId, screenScale: screenScale)
        default:
            fatalError("해당 플랫폼의 구현이 아직 진행되지 않았음")
        }
    }
    
    public func save(videoCode: String, url: String) {
        
        localRepository.save(videoCode: videoCode, url: url)
    }
    
    public func fetchFromLocal(videoCode: String) -> String? {
        
        return localRepository.fetch(videoCode: videoCode)
    }
    
    func extractYouTubeID(target: String) -> String? {
        let pattern = "(?<=v=|youtu.be/|/embed/|/v/|/shorts/|youtu.be/shorts/|/vi/)[a-zA-Z0-9_-]{11}"
        let regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: target.utf16.count)
        
        guard let match = regex.firstMatch(in: target, options: [], range: range) else {
            return nil
        }
        
        return (target as NSString).substring(with: match.range)
    }
}
