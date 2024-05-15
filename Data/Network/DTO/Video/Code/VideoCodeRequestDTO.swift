import Foundation
import Domain

/// 요약 시작 요청을 위해 사용되는 구조체입니다.
struct VideoCodeRequestDTO: Encodable {
    
    let url: String
    let categoryId: String?
    let categoryIncluded: Bool
}
