import Foundation

public protocol VideoCodeStorage {
    
    func save(
        videoCodeDTO: VideoCodeDTO,
        completion: @escaping (Result<VideoCodeDTO, Error>) -> Void
    )
    
    func getResponse(
        completion: @escaping (Result<[VideoCodeDTO], Error>) -> Void
    )
}
