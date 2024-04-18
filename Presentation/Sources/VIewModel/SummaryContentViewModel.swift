import UIKit
import Domain
import RxSwift
import RxCocoa

public class SummaryContentViewModel {
    
    private let getRowDataUseCase: GetRowDataUseCaseInterface
    private let saveSummaryDataUseCase: SaveSummaryDataUseCaseInterface
    
    let rowDataRelay: BehaviorRelay<[SummaryResultEntity]> = BehaviorRelay(value: [])
    
    let disposeBag = DisposeBag()
    
    public init(
        getRowDataUseCase: GetRowDataUseCaseInterface,
        saveSummaryDataUseCase: SaveSummaryDataUseCaseInterface
    ) {
        self.getRowDataUseCase = getRowDataUseCase
        self.saveSummaryDataUseCase = saveSummaryDataUseCase
    }
    
    func initialBindingForRx(tableView: UITableView) {
        
        _ = rowDataRelay
            .bind(to: tableView.rx.items(cellIdentifier: String(describing: SummaryContentRowCell.self), cellType: SummaryContentRowCell.self)) { _, item, cell in
                
                cell.setUp(entity: item, viewModel: self)
            }
    }
    
    /// 확장앱에서 저장한 비디오 코드를 영구저장소로 옮깁니다. 그 후 저장된 데이터를 방출합니다.
    func fetchFreshData() {
        
        Task {
            
            try getRowDataUseCase.moveVideoCodeToStore()
            
            fetchDataFromStore()
        }
    }
    
    /// 영구저장소에 저정된 정보를 로드합니다.
    func fetchDataFromStore() {
        
        Task {
            
            let entities = await getRowDataUseCase.getDataFromStore()
            
            rowDataRelay
                .accept(entities)
        }
    }
    
    
    // MARK: - For Cell
    
    /// 요약상태를 확인합니다.
    func checkStatusFor(code: String) async throws -> SummaryStatusEntity {
        
        try await getRowDataUseCase.checkSummaryStateFor(code: code)
    }
    
    /// 요약상태확인후 데이터를 가져옵니다.
    func getSummaryResultFor(code: String, seconds: CGFloat = 1.5) async throws -> SummaryResultEntity {
        
        while(true) {
            
            print("👀 \(code) 요약상태 확인중...")
            
            let entity = try await checkStatusFor(code: code)
            
            if entity.status == .complete {
                
                let id = entity.videoId
                
                print("✅ \(code) 요약완료, id: \(id)")
                
                return try await getRowDataUseCase.getSummaryResultFor(id: id)
            }
            try await Task.sleep(for: .seconds(seconds))
        }
    }
    
    /// 요약된 정보를 저장합니다.
    func updateStoreWith(entity: SummaryResultEntity) async {
        
        await saveSummaryDataUseCase.updateStore(entity: entity)
    }
}
