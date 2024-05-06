import Foundation

public protocol UrlValidationUseCase {
    
    func excute(url: String) -> Bool
}

public final class DefaultUrlValidationUseCase: UrlValidationUseCase {
    
    static let instagramRegexStr = "((http|https):\\/\\/)*(www.)*instagram.com\\/reel\\/.*"
    static let youtubeRegexStr = "((http|https):\\/\\/)*(www.)*(m.)*youtube.com\\/shorts\\/.*"
    
    public init() { }
    
    public func excute(url: String) -> Bool {
        
        let patterns = [
            Self.instagramRegexStr,
            Self.youtubeRegexStr
        ]
        
        for pattern in patterns {
            
            guard let regex = try? NSRegularExpression(pattern: pattern) else {
                fatalError("Invalid regular expression pattern")
            }
            
            if let matchedResult = regex.matches(in: url, range: NSRange(url.startIndex..., in: url)).first {
                
                if matchedResult.range.length == url.count {
                    
                    return true
                }
            }
        }
        
        return false
    }
}
