import Foundation
import Domain

struct VideoSummaryStateResponseDTO: Decodable {
    
    var status: String?
    var videoSummaryId: Int?
    
    func toDomain() -> VideoSummaryState {
        
        VideoSummaryState(
            status: .init(rawValue: status ?? "") ?? .processing,
            videoId: videoSummaryId ?? -1
        )
    }
}
