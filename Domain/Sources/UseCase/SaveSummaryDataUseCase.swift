import Foundation

public protocol SaveSummaryDataUseCaseInterface {
    
    /// 로컬에 요약된 정보를 저장한다(업데이트)
    func updateStore(entity: SummaryResultEntity) async
}

public final class SaveSummaryDataUseCase: SaveSummaryDataUseCaseInterface {

    let storeRepo: StoreRepositoryInterface
        
    public init(storeRepo: StoreRepositoryInterface) {
        self.storeRepo = storeRepo
    }
    
    public func updateStore(entity: SummaryResultEntity) async {
        
        await storeRepo.updateData(entities: [entity])
    }
}
