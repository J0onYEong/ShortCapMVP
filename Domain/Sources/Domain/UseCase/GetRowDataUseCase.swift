import Foundation

public protocol GetRowDataUseCaseInterface {
    
    func moveVideoCodeToStore() throws
    func checkSummaryStateFor(code: String) async throws -> SummaryStatusEntity
    func getSummaryResultFor(code: String) async throws -> SummaryResultEntity
    func getDataFromStore() async -> [SummaryResultEntity]
}

public final class GetRowDataUseCase: GetRowDataUseCaseInterface {
    
    let summaryRepo: SummaryRepositoryInterface
    let videoCodeRepo: VideoCodeRepositoryInterface
    let storeRepo: StoreRepositoryInterface
    
    public init(
        summaryRepo: SummaryRepositoryInterface,
        videoCodeRepo: VideoCodeRepositoryInterface,
        storeRepo: StoreRepositoryInterface
    ) {
        self.summaryRepo = summaryRepo
        self.videoCodeRepo = videoCodeRepo
        self.storeRepo = storeRepo
    }
    
    public func moveVideoCodeToStore() throws {
        let entities = videoCodeRepo.get().map { SummaryResultEntity(videoCode: $0.videoCode) }
        
        storeRepo.saveData(entities: entities)
    }
    
    public func checkSummaryStateFor(code: String) async throws -> SummaryStatusEntity {
        
        try await summaryRepo.requestStatusFor(videoCode: code)
    }
    
    public func getSummaryResultFor(code: String) async throws -> SummaryResultEntity {
        
        try await summaryRepo.requestResultFor(videoCode: code)
    }
    
    public func getDataFromStore() async -> [SummaryResultEntity] {
        
        await storeRepo.getData()
    }
}
