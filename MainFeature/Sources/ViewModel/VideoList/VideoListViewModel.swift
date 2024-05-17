import Foundation
import RxSwift
import RxCocoa
import Core
import Domain
import Data

public protocol VideoListViewModelInterface {
    
    var displayingVideoCellViewModel: BehaviorRelay<[VideoCellViewModelInterface]> { get }
    var filterdVideoCellViewModel: BehaviorRelay<[VideoCellViewModelInterface]> { get }
    
    func fetchVideoIdentities()
}

public class DefaultVideoListViewModel: VideoListViewModelInterface {
    
    private let fetchVideoIdentityUseCase: FetchVideoIdentityUseCase
    private let videoCellViewModelFactory: VideoCellViewModelFactory
    
    /// 로컬에서 불러들여진 새로운 비디오 아티덴티티들입니다.
    private let fetchedVideoIdentites = PublishRelay<[VideoIdentity]>()
    
    /// 현재까지 패치된 비디오 아이덴티티들입니다.
    private var currentVideoIdentities = Set<VideoIdentity>()
    
    /// 패치된 아이덴티티로 부터 디테일과 썸네일이 획득된 ViewModel입니다.
    private let createdVideoCellViewModel = PublishRelay<VideoCellViewModelInterface>()
    
    /// 화면에 표시가능한 뷰모델 배열입니다.
    public let displayingVideoCellViewModel = BehaviorRelay<[VideoCellViewModelInterface]>(value: [])
    
    /// 필터링이 적용된 뷰묘델 배열입니다, 이 옵저버블이 최종적으로 UI구성에 사용됩니다.
    public let filterdVideoCellViewModel = BehaviorRelay<[VideoCellViewModelInterface]>(value: [])
    
    private let disposeBag: DisposeBag = .init()
    
    public init(
        fetchVideoIdentityUseCase: FetchVideoIdentityUseCase,
        videoCellViewModelFactory: VideoCellViewModelFactory
    ) {
        self.fetchVideoIdentityUseCase = fetchVideoIdentityUseCase
        self.videoCellViewModelFactory = videoCellViewModelFactory
        
        setObserver()
        
        fetchVideoIdentities()
    }
    
    private func setObserver() {
        
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
            .scan([]) { (viewModels: [VideoCellViewModelInterface], viewModel) in
                
                var copy = viewModels
                
                copy.append(viewModel)
                
                return copy
            }
            .map({ $0.sorted { lhs, rhs in lhs.detail!.createdAt > rhs.detail!.createdAt } })
            .subscribe(onNext: {
                
                self.displayingVideoCellViewModel
                    .accept($0)
            })
            .disposed(by: disposeBag)
        
        
        // MARK: - NotificationCenter, 메인카테고리의 변경을 수신합니다.
        let filterObservable = NotificationCenter.mainFeature.rx.notification(.videoSubCategoryClicked)
            .map { notification in
                
                guard let videoFilter: VideoFilter = notification[.videoFilter] else { fatalError() }
                
                return videoFilter
            }
        
        // 필터링
        Observable
            .combineLatest(filterObservable, displayingVideoCellViewModel)
            .subscribe(onNext: { [weak self] (filter, viewModels) in
                
                if filter.state == .all {
                    
                    self?.filterdVideoCellViewModel.accept(viewModels)
                }
                
                if filter.state != .all {
                    
                    let filetered = viewModels.filter { viewModel in
                        
                        let mainCategoryId = viewModel.detail!.mainCategoryId
                        let subCategoryId = viewModel.detail!.subCategoryId
                        
                        return filter.mainCategoryId == mainCategoryId && filter.subCategoryId == subCategoryId
                    }
                    
                    self?.filterdVideoCellViewModel.accept(filetered)
                }
                
            })
            .disposed(by: disposeBag)
        
        
        // 현재 어떤 메인카테고리의 서브카테고리에 포함된 비디오가 몇개인지 정보 전송
        displayingVideoCellViewModel
            .subscribe(onNext: { activeViewModels in
                
                var information: VideoCategoryInformation = [:]
                
                activeViewModels.forEach { viewModel in
                    
                    let mainCategoryId = viewModel.detail!.mainCategoryId
                    let subCategoryId = viewModel.detail!.subCategoryId
                    let creationDateString = viewModel.detail!.createdAt
                    
                    if let mainInfo = information[mainCategoryId] {
                        
                        if let subInfo = mainInfo[subCategoryId] {
                                
                            subInfo.count+=1
                        } else {
                            
                            information[mainCategoryId]![subCategoryId] = VideoSubCategoryInformation(count: 1, creationDateString: creationDateString)
                        }
                        
                    } else {
                        
                        information[mainCategoryId] = [subCategoryId : VideoSubCategoryInformation(count: 1, creationDateString: creationDateString)]
                    }
                }
                
                NotificationCenter.videoCategoryInformation.accept(information)
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
