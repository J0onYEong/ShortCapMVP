import Foundation

public protocol SaveVideoCodeRepository {
    
    func save(
        videoCode: String,
        completion: @escaping (String?) -> Void
    )
}
