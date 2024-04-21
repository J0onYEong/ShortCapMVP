import Foundation

public protocol SaveVideoCodeRepository {
    
    func save(
        videoCode: VideoCode,
        completion: @escaping (VideoCode?) -> Void
    )
}
