import Foundation

public protocol VideoDetailStorage {
    
    func save(detail: VideoDetailDTO, completion: @escaping (Result<VideoDetailDTO, Error>) -> Void)
    func fetch(videoCode: String, completion: @escaping (Result<VideoDetailDTO?, Error>) -> Void)
}
