import Foundation
import Domain

public final class StoreRepository: StoreRepositoryInterface {

    public init() { }
    
    public func getData() async -> [Domain.SummaryResultEntity] {
        ShortCapContainer.shared.getSummaryContent()
    }
    
    public func saveData(entities: [Domain.SummaryResultEntity]) {
        ShortCapContainer.shared.saveSummaryContent(entities: entities)
    }
    
    public func updateData(entities: [Domain.SummaryResultEntity]) async {
        ShortCapContainer.shared.updateSummaryContent(entities: entities)
    }
    
}
