import UIKit
import RxSwift
import RxCocoa
import Core
import Domain

public protocol VideoCollectionViewModel {
    
    var newVideoIdentities: PublishRelay<[VideoIdentity]> { get }
    
    var videoCellViewModel: PublishRelay<VideoCellViewModel> { get }
    
    /// 화면에 표시되는 ViewModel입니다.
    var displayCellViewModel: BehaviorRelay<[VideoCellViewModel]> { get }
    
    func fetchVideoIdentities()
}

enum Section {
    
    case main
}

public class DefaultVideoCollectionViewModel: VideoCollectionViewModel {
    
    let fetchVideoIdentityUseCase: FetchVideoIdentityUseCase
    let cellVMFactory: VideoCellViewModelFactory
    
    public let newVideoIdentities: PublishRelay<[VideoIdentity]> = .init()
    
    private var currentIdentities: Set<VideoIdentity> = .init()
    
    public let videoCellViewModel: PublishRelay<VideoCellViewModel> = .init()
    public let displayCellViewModel: BehaviorRelay<[VideoCellViewModel]> = .init(value: [])
    
    private let disposeBag: DisposeBag = .init()
    
    public init(
        fetchVideoIdentityUseCase: FetchVideoIdentityUseCase,
        cellVMFactory: VideoCellViewModelFactory
    ) {
        self.fetchVideoIdentityUseCase = fetchVideoIdentityUseCase
        self.cellVMFactory = cellVMFactory
        
        newVideoIdentities
            .subscribe(onNext: { identities in
                
                printIfDebug("✅ \(identities.count)개의 비디오가 추가될 예정입니다.")
                
                identities
                    .forEach { identity in
                        
                        let cellVm = cellVMFactory.makeVm(videoIdentity: identity)
                        
                        Observable.zip(
                            cellVm.detailSubject,
                            cellVm.thumbNailSubject
                        )
                        .observe(on: MainScheduler.asyncInstance)
                        .subscribe(onNext: { _ in
                            
                            self.videoCellViewModel
                                .accept(cellVm)
                        })
                        .disposed(by: self.disposeBag)
                        
                        cellVm.fetchDetailAndThumbNail()
                    }
                
            })
            .disposed(by: disposeBag)
        
        
        videoCellViewModel
            .scan([]) { (accum: [VideoCellViewModel], newValue) in
                var newAccum = accum
                
                newAccum.append(newValue)
                
                return newAccum
            }
            .subscribe(onNext: {
                
                self.displayCellViewModel
                    .accept($0)
            })
            .disposed(by: disposeBag)
        
    }
    
    /// #1
    public func fetchVideoIdentities() {
        
        fetchVideoIdentityUseCase.execute { result in
            
            switch result {
            case .success(let identities):
                
                let newIdentities = identities.filter { !self.currentIdentities.contains($0) }
                
                // 새로운 것만 accept
                self.newVideoIdentities
                    .accept(newIdentities)
                
                // 현재 보유중인 아이덴티티들 업데이트
                self.currentIdentities = Set(identities)
                
            case .failure(let failure):
                
                printIfDebug("‼️비디오 코드 불러오기 실패: \(failure.localizedDescription)")
            }
        }
    }
}

public class VideoCellViewModelFactory {
    
    private let checkStateUC: CheckSummaryStateUseCase
    private let fetchDetailUC: FetchVideoDetailUseCase
    private let saveDetailUC: SaveVideoDetailUseCase
    private let thumbNailUC: VideoThumbNailUseCase
    
    public init(
        checkSummaryStateUseCase checkStateUC: CheckSummaryStateUseCase,
        fetchVideoDetailUseCase fetchDetailUC: FetchVideoDetailUseCase,
        saveVideoDetailUseCase saveDetailUC: SaveVideoDetailUseCase,
        videoThumbNailUseCase thumbNailUC: VideoThumbNailUseCase
    ) {
        self.checkStateUC = checkStateUC
        self.fetchDetailUC = fetchDetailUC
        self.saveDetailUC = saveDetailUC
        self.thumbNailUC = thumbNailUC
    }
    
    func makeVm(videoIdentity: VideoIdentity) -> VideoCellViewModel {
        
        DefaultVideoCellViewModel(
            videoIdentity: videoIdentity,
            checkSummaryStateUseCase: checkStateUC,
            fetchVideoDetailUseCase: fetchDetailUC,
            saveVideoDetailUseCase: saveDetailUC,
            videoThumbNailUseCase: thumbNailUC
        )
    }
}
