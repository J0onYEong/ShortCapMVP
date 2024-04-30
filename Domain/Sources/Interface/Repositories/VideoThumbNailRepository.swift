
public protocol VideoThumbNailRepository {
    
    func fetch(videoId: String, screenScale: CGFloat) async throws -> VideoThumbNailInformation
}

// 인터페이스를 의존하는 레포지토리에서 사용가능한 에러
public enum FetchVideoThumbNailError: Error {
    
    case dataNotFound(describing: String)
}
