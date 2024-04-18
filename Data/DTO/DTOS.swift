import Foundation
import Domain

struct BaseDTO<T: Decodable>: Decodable {
    
    var result: String?
    var message: String?
    var data: T?
}


// MARK: - 요약 시작 요청

/// 요약 시작 요청
struct InitiateSummaryRequestDTO: Encodable {
    
    let url: String
    let categoryId: String?
    let categoryIncluded: Bool
}

/// 요약 시작 응답
struct InitiateSummaryResponseDTO: Decodable {
    
    var videoCode: String
    var categoryId: Int?
    private var categoryIncluded: Bool { categoryId != nil }
}

typealias InitiateSummaryResponseDTOWithBase = BaseDTO<InitiateSummaryResponseDTO>


// MARK: - 요약 상태 확인
struct SummaryStatusResponseDTO: Decodable {
    
    var status: String
    var videoId: Int
    
    enum CodingKeys: String, CodingKey {
        
        case status = "status"
        case videoId = "videoSummaryId"
    }
    
    func transformToEntity() -> SummaryStatusEntity {
        
        SummaryStatusEntity(
            status: SummaryStatusEntity.Status.status(self.status),
            videoId: self.videoId
        )
    }
}

typealias SummaryStatusResponseDTOWithBase = BaseDTO<SummaryStatusResponseDTO>


// MARK: - 요약 정보 가져오기
struct SummaryResultResponseDTO: Decodable {
    
    var title: String
    var description: String
    var keywords: [String]
    var url: String
    var summary: String
    var address: String
    var createdAt: String
    var platform: String
    var mainCategory: String
    var videoCode: String
    
    enum CodingKeys: String, CodingKey {
        
       case title = "title"
       case description = "description"
       case keywords = "keywords"
       case url = "url"
       case summary = "summary"
       case address = "address"
       case createdAt = "createdAt"
       case platform = "platform"
       case mainCategory = "mainCategory"
       case videoCode = "video_code"
    }
}

typealias SummaryResultResponseDTOWithBase = BaseDTO<SummaryResultResponseDTO>

