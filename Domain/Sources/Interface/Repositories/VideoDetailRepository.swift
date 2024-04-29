import Foundation

public protocol VideoDetailLocalRepository {
    
    func save(
        videoCode: VideoCode,
        detail: VideoDetail,
        completion: @escaping (Result<VideoDetail, Error>) -> Void
    )
    
    // 비디오 코드를 기본키로, 로컬저장소에서 영샹 요약정보를 가져온다.
    func fetch(videoCode: VideoCode, completion: @escaping (Result<VideoDetail, Error>) -> Void)
}
