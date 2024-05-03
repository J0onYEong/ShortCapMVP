import Foundation

public protocol SummaryProcessRepository {
    
    func state(videoCode: String, completion: @escaping ((Result<VideoSummaryState, Error>) -> Void))
    func detail(videoId: Int, completion: @escaping ((Result<VideoDetail, Error>) -> Void))
}

// 인터페이스를 의존하는 레포지토리에서 사용가능한 에러
public enum SummaryProcessError: Error {
    
    case unknownError
}
