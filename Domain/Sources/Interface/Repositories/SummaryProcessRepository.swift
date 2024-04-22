import Foundation

public protocol SummaryProcessRepository {
    
    func state(videoCode: VideoCode, completion: @escaping ((Result<VideoSummaryState, Error>) -> Void))
    func detail(videoId: Int, completion: @escaping ((Result<VideoDetail, Error>) -> Void))
}
