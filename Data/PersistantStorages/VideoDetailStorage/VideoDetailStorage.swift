import Foundation

public protocol VideoDetailStorage {
    
    func save(
        videoCode: VideoCodeDTO,
        detail: VideoDetailDTO,
        completion: @escaping (Result<VideoDetailDTO, Error>) -> Void)
    func fetch(videoCode: VideoCodeDTO, completion: @escaping (Result<VideoDetailDTO?, Error>) -> Void)
}
