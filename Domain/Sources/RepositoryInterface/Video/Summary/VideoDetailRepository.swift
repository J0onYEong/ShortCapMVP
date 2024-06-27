import Foundation

public protocol VideoDetailLocalRepository {
    
    func save(detail: VideoDetail, completion: @escaping (Bool) -> Void)
    
    // 비디오 코드를 기본키로, 로컬저장소에서 영샹 요약정보를 가져온다.
    func fetch(videoCode: String, completion: @escaping (Result<VideoDetail?, Error>) -> Void)
}

// 인터페이스를 의존하는 레포지토리에서 사용가능한 에러
public enum FetchVideoDetailFromLocalError: Error {
    
    case dataNotFound
}
