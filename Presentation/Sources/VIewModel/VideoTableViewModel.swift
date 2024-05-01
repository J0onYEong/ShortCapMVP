import UIKit
import RxSwift
import RxCocoa
import Core
import Domain

public protocol VideoTableViewModel {
    
    var rowDataRelay: BehaviorRelay<[VideoCode]> { get set }
    
    func bindWith(collectionView: UICollectionView)
    
    func fetchList()
}

public class DefaultVideoTableViewModel: VideoTableViewModel {
    
    let fetchVideoCodeUseCase: FetchVideoCodesUseCase
    let videoCellViewModel: VideoCellViewModel
    
    public var rowDataRelay: BehaviorRelay<[VideoCode]> = BehaviorRelay(value: [])
    
    public init(
        fetchVideoCodeUseCase: FetchVideoCodesUseCase,
        videoCellViewModel: VideoCellViewModel
    ) {
        self.fetchVideoCodeUseCase = fetchVideoCodeUseCase
        self.videoCellViewModel = videoCellViewModel
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
            .observe(on: MainScheduler.instance)
            .bind(to: collectionView.rx.items(cellIdentifier: String(describing: CellType.self),
                                         cellType: CellType.self)) { (index: Int, item: VideoCode, cell: CellType) in
                
                cell.setUp(videoCode: item, viewModel: self.videoCellViewModel)
            }
    }
}
