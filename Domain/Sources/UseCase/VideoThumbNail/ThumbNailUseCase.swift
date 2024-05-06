import Foundation

public protocol VideoThumbNailUseCase {
    
    func fetch(videoIdentity: VideoIdentity, screenScale: CGFloat) async throws -> VideoThumbNailInformation
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
    
    public func fetch(
        videoIdentity: VideoIdentity,
        screenScale: CGFloat) async throws -> VideoThumbNailInformation {

        let splited = videoIdentity.videoCode.split(separator: "_")
            
        let platform = VideoPlatform(rawValue: String(splited[0]))!
        let platform_id = splited[1]
        
        switch platform {
        case .youtube:
            
            guard let videoId = extractYouTubeID(target: videoIdentity.originUrl) else { fatalError() }
            
            return try await youtubeRepository.fetch(videoIdForPlatform: videoId, screenScale: screenScale)
            
        default:
            
            #if Device_Debug
            print("썸네일을 가져오는 도중 문제발생 url: \(videoIdentity.originUrl)")
            #endif
            
            throw VideoThumbNailUseCaseError.notImplemented
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

public enum VideoThumbNailUseCaseError: Error {
    
    case notImplemented
}
