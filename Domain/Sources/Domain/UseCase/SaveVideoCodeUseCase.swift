import Foundation

public protocol SaveVideoCodeUseCaseInterface {
    
    func checkUrlFormIsValid(urlString: String) -> Bool
    func getVideoCodeFrom(urlString: String) async throws -> SummaryIntiationEntitiy
    func saveVideoCode(videoCode: String)
}

public final class SaveVideoCodeUseCase: SaveVideoCodeUseCaseInterface {
    
    let summaryRepo: SummaryRepositoryInterface
    let videoRepo: VideoCodeRepositoryInterface
    
    public init(summaryRepo: SummaryRepositoryInterface, videoRepo: VideoCodeRepositoryInterface) {
        self.summaryRepo = summaryRepo
        self.videoRepo = videoRepo
    }
    
    static let instagramRegexStr = "((http|https):\\/\\/)*(www.)*instagram.com\\/reel\\/.*"
    static let youtubeRegexStr = "((http|https):\\/\\/)*(www.)*(m.)*youtube.com\\/shorts\\/.*"
    
    public func checkUrlFormIsValid(urlString: String) -> Bool {
        
        let patterns = [
            Self.instagramRegexStr,
            Self.youtubeRegexStr
        ]
        
        for pattern in patterns {
            
            guard let regex = try? NSRegularExpression(pattern: pattern) else {
                fatalError("Invalid regular expression pattern")
            }
            
            if let matchedResult = regex.matches(in: urlString, range: NSRange(urlString.startIndex..., in: urlString)).first {
                
                if matchedResult.range.length == urlString.count {
                    
                    return true
                }
            }
        }
        
        return false
    }
    
    public func getVideoCodeFrom(urlString: String) async throws -> SummaryIntiationEntitiy {
        
        try await summaryRepo.initiateSummaryWith(url: urlString)
    }
    
    public func saveVideoCode(videoCode: String) {
        
        videoRepo.save(code: videoCode)
    }
}
