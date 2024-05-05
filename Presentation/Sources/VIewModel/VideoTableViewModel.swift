import UIKit
import RxSwift
import RxCocoa
import Core
import Domain

public protocol VideoTableViewModel {
    
    var rowDataRelay: BehaviorRelay<[String]> { get }
    
    func bindWith(collectionView: UICollectionView)
    
    func fetchList()
}

public class DefaultVideoTableViewModel: VideoTableViewModel {
    
    let fetchVideoCodeUseCase: FetchVideoCodesUseCase
    let cellVMFactory: VideoCellViewModelFactory
    
    public let rowDataRelay: BehaviorRelay<[String]> = BehaviorRelay(value: [])
    
    public init(
        fetchVideoCodeUseCase: FetchVideoCodesUseCase,
        cellVMFactory: VideoCellViewModelFactory
    ) {
        self.fetchVideoCodeUseCase = fetchVideoCodeUseCase
        self.cellVMFactory = cellVMFactory
    }
    
    public func fetchList() {
        
        fetchVideoCodeUseCase.execute { result in
            
            switch result {
            case .success(let videoCodes):
                
                self.rowDataRelay
                    .accept(videoCodes)
                
            case .failure(let failure):
                
                printIfDebug("‼️비디오 코드 불러오기 실패: \(failure.localizedDescription)")
            }
        }
    }
    
    public func bindWith(collectionView: UICollectionView) {
        
        typealias CellType = VideoCollectionViewCell
        
        _ = rowDataRelay
            .asDriver()
            .drive(collectionView.rx.items(cellIdentifier: String(describing: CellType.self),
                                           cellType: CellType.self)) { (index: Int, item: String, cell: CellType) in
                
                cell.setUp(viewModel: self.cellVMFactory.create(item: item))
            }
    }
}
