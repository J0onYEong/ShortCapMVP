import Foundation

public protocol SummaryProcessRepository {
    
    func state(videoCode: String, completion: @escaping ((Result<VideoSummaryState, Error>) -> Void))
}
