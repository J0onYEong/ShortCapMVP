import Foundation
import Domain

/// 요약 시작 응답
struct VideoCodeResponseDTO: Decodable {
    
    var videoCode: String?
    
    func toDomain() -> VideoCode {
        
        VideoCode(code: videoCode ?? "Uknown code")
    }
}
