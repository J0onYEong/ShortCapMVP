import Foundation
import Domain

/// 요약 시작 요청
struct VideoCodeRequestDTO: Encodable {
    
    let url: String
    let categoryId: String?
    let categoryIncluded: Bool
}
