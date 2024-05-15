import Foundation
import RxSwift
import RxCocoa
import Core
import Domain
import Data

public class VideoListViewModel {
    
    private let fetchVideoIdentityUseCase: FetchVideoIdentityUseCase
    private let videoCellViewModelFactory: VideoCellViewModelFactory
    
    /// 로컬에서 불러들여진 새로운 비디오 아티덴티티들입니다.
    private let fetchedVideoIdentites = PublishRelay<[VideoIdentity]>()
    
    /// 현재까지 패치된 비디오 아이덴티티들입니다.
    private var currentVideoIdentities = Set<VideoIdentity>()
    
    /// 패치된 아이덴티티로 부터 디테일과 썸네일이 획득된 ViewModel입니다.
    private let createdVideoCellViewModel = PublishRelay<VideoCellViewModel>()
    
    /// 화면에 표시가능한 뷰모델 배열입니다.
    private let displayingVideoCellViewModel = BehaviorRelay<[VideoCellViewModel]>(value: [])
    
    /// 필터링이 적용된 뷰묘델 배열입니다, 이 옵저버블이 최종적으로 UI구성에 사용됩니다.
    public let filterdVideoCellViewModel = BehaviorRelay<[VideoCellViewModel]>(value: [])
    
    private let disposeBag: DisposeBag = .init()
    
    public init(
        fetchVideoIdentityUseCase: FetchVideoIdentityUseCase,
        videoCellViewModelFactory: VideoCellViewModelFactory
    ) {
        self.fetchVideoIdentityUseCase = fetchVideoIdentityUseCase
        self.videoCellViewModelFactory = videoCellViewModelFactory
        
        setOnserver()
    }
    
    private func setOnserver() {
        
        fetchedVideoIdentites
            .subscribe(onNext: { identities in
                
                printIfDebug("✅ \(identities.count)개의 비디오가 추가될 예정입니다.")
                
                identities
                    .forEach { identity in
                        
                        let cellViewModel = self.videoCellViewModelFactory.create(videoIdentity: identity)
                        
                        Observable.zip(
                            cellViewModel.detailSubject,
                            cellViewModel.thumbNailSubject
                        )
                        .observe(on: MainScheduler.asyncInstance)
                        .subscribe(onNext: { _ in
                            
                            self.createdVideoCellViewModel
                                .accept(cellViewModel)
                        })
                        .disposed(by: self.disposeBag)
                        
                        // 옵저버를 설정한 이후 디테일정보를 가져오는 작업을 실행
                        cellViewModel.fetchDetailAndThumbNail()
                    }
                
            })
            .disposed(by: disposeBag)
        
        
        createdVideoCellViewModel
            .scan([]) { (viewModels: [VideoCellViewModel], viewModel) in
                
                var copy = viewModels
                
                copy.append(viewModel)
                
                return copy
            }
            .subscribe(onNext: {
                
                self.displayingVideoCellViewModel
                    .accept($0)
            })
            .disposed(by: disposeBag)
        
        
        // MARK: - NotificationCenter, 메인카테고리의 변경을 수신합니다.
        let filterObservable = NotificationCenter.default.rx.notification(.mainCategoryIsChanged)
            .map { notification in
                
                guard let videoFilter: VideoFilter = notification.getUserInfo(key: .videoFilter) else { fatalError() }
                
                return videoFilter
            }
        
        // 필터링
        Observable
            .combineLatest(filterObservable, displayingVideoCellViewModel)
            .subscribe(onNext: { [weak self] (filter, viewModels) in
                
                let filetered = viewModels.filter { viewModel in
                    
                    let mainCategoryId = viewModel.detail.mainCategoryId
                    let subCategoryId = viewModel.detail.subCategoryId
                    
                    return filter.mainCategoryId == mainCategoryId && filter.subCategoryId == subCategoryId
                }
                
                self?.filterdVideoCellViewModel.accept(filetered)
            })
            .disposed(by: disposeBag)
    }
    
    /// 로커저장소에서 비디오 아이덴티티를 가져옵니다.
    public func fetchVideoIdentities() {
        
        fetchVideoIdentityUseCase.execute { result in
            
            switch result {
            case .success(let identities):
                
                let newIdentities = identities.filter { !self.currentVideoIdentities.contains($0) }
                
                // 새로운 것만 accept
                self.fetchedVideoIdentites
                    .accept(newIdentities)
                
                // 현재 보유중인 아이덴티티들 업데이트
                self.currentVideoIdentities = Set(identities)
                
            case .failure(let failure):
                
                printIfDebug("‼️비디오 코드 불러오기 실패: \(failure.localizedDescription)")
            }
        }
    }
}
