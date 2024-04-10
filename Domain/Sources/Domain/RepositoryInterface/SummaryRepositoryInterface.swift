import Foundation

public protocol SummaryRepositoryInterface {
    
    func initiateSummaryWith(url: String) async throws -> SummaryIntiationEntitiy
    func requestStatusFor(videoCode: String) async throws -> SummaryStatusEntity
    func requestResultFor(videoCode: String) async throws -> SummaryResultEntity
}
