import Foundation

public protocol StoreRepositoryInterface {
    
    func getData() async -> [SummaryResultEntity]
    func saveData(entities: [SummaryResultEntity])
    func updateData(entities: [SummaryResultEntity]) async
}
