import Foundation

public protocol VideoDetailRepository {
    
    func save(
        videoCode: VideoCode,
        detail: VideoDetail,
        completion: @escaping (Result<VideoDetail, Error>) -> Void
    )
    func fetch(videoCode: VideoCode, completion: @escaping (Result<VideoDetail, Error>) -> Void)
}
