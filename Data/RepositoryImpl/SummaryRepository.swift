import Foundation
import Domain

public final class SummaryRepository: SummaryRepositoryInterface {
    
    public init() { }
    
    public func initiateSummaryWith(url: String) async throws -> Domain.SummaryIntiationEntitiy {
        
        let requestDTO = InitiateSummaryRequestDTO(
            url: url,
            categoryId: nil,
            categoryIncluded: false
        )
        
        let responseDTO: InitiateSummaryResponseDTOWithBase = try await SummaryRestAPIService.default.makeRequest(
            .excute,
            body: requestDTO
        )
        
        return SummaryIntiationEntitiy(videoCode: responseDTO.data!.videoCode)
    }
    
    public func requestStatusFor(videoCode: String) async throws -> Domain.SummaryStatusEntity {
        
        let responseDTO: SummaryStatusResponseDTOWithBase = try await SummaryRestAPIService.default.makeRequest(.check(videoId: videoCode))
        
        return responseDTO.data!.transformToEntity()
    }
    
    public func requestResultFor(videoId: Int) async throws -> Domain.SummaryResultEntity {
        
        let responseDTO: SummaryResultResponseDTOWithBase = try await SummaryRestAPIService.default.makeRequest(.data(id: videoId))
        
        let data = responseDTO.data!
        
        return SummaryResultEntity(
            title: data.title,
            description: data.description,
            keywords: data.keywords,
            url: data.url,
            summary: data.summary,
            address: data.address,
            createdAt: data.createdAt,
            platform: data.platform,
            mainCategory: data.mainCategory,
            videoCode: data.videoCode,
            isFetched: true
        )
    }
}
