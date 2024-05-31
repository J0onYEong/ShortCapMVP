import Foundation
import RxSwift
import RxCocoa
import Core
import Domain
import Data

public protocol VideoListViewModelInterface {
    
    // 테스트를 위해서
    var displayingVideoCellViewModel: BehaviorRelay<[VideoCellViewModelInterface]> { get }
    
    func fetchVideoIdentities()
}

public class DefaultVideoListViewModel: VideoListViewModelInterface {
    
    private let fetchVideoIdentityUseCase: FetchVideoIdentityUseCase
    private let videoCellViewModelFactory: VideoCellViewModelFactory
    
    /// 로컬에서 불러들여진 새로운 비디오 아티덴티티들입니다.
    private let fetchedVideoIdentites = PublishSubject<[VideoIdentity]>()
    
    /// 현재까지 패치된 비디오 아이덴티티들입니다.
    private var currentVideoIdentities = Set<VideoIdentity>()
    
    /// 패치된 아이덴티티로 부터 디테일과 썸네일이 획득된 ViewModel입니다.
    private let createdVideoCellViewModel = PublishRelay<VideoCellViewModelInterface>()
    
    /// 화면에 표시가능한 뷰모델 배열입니다.
    public let displayingVideoCellViewModel = BehaviorRelay<[VideoCellViewModelInterface]>(value: [])
    
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
            .flatMap { identities in
                
                printIfDebug("✅ \(identities.count)개의 비디오가 추가될 예정입니다.")
                
                return Observable.from(identities)
            }
            .compactMap { [weak self] identity in
                self?.videoCellViewModelFactory.create(videoIdentity: identity)
            }
            .flatMap { cellViewModel in
                
                let observable = Observable.zip(
                    cellViewModel.detailSubject,
                    cellViewModel.thumbNailSubject
                ).map { _ in cellViewModel }
                
                cellViewModel.fetchDetailAndThumbNail()
                
                return observable
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] loadedCellViewModel in
                            
                self?.createdVideoCellViewModel
                    .accept(loadedCellViewModel)
            })
            .disposed(by: disposeBag)
            
        createdVideoCellViewModel
            .scan([]) { (viewModels: [VideoCellViewModelInterface], viewModel) in
                
                var copy = viewModels
                
                copy.append(viewModel)
                
                return copy
            }
            .map({ $0.sorted { lhs, rhs in lhs.detail!.createdAt > rhs.detail!.createdAt } })
            .subscribe(onNext: { [weak self] in
                
                self?.displayingVideoCellViewModel
                    .accept($0)
            })
            .disposed(by: disposeBag)

        
        // 현재 어떤 메인카테고리의 서브카테고리에 포함된 비디오가 몇개인지 정보 전송
        displayingVideoCellViewModel
            .subscribe(onNext: { activeViewModels in
                
                var mappingResult: VideoCategoryMappingResult = [:]
                
                activeViewModels.forEach { viewModel in
                    
                    let mainCategoryId = viewModel.detail!.mainCategoryId
                    let subCategoryId = viewModel.detail!.subCategoryId
                    let creationDateString = viewModel.detail!.createdAt
                    
                    if let mainInfo = mappingResult[mainCategoryId] {
                        
                        if let subInfo = mainInfo[subCategoryId] {
                                
                            subInfo.count+=1
                        } else {
                            
                            mappingResult[mainCategoryId]![subCategoryId] = VideoSubCategoryMappingResult(count: 1, creationDateString: creationDateString)
                        }
                        
                    } else {
                        
                        mappingResult[mainCategoryId] = [subCategoryId : VideoSubCategoryMappingResult(count: 1, creationDateString: creationDateString)]
                    }
                }
                
                // 변경된 비디오 맵핑 정보를 각 서브카테고리의 셀에 전달합니다.
                NotificationCenter.videoCategoryMappingResult.accept(mappingResult)
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
                    .onNext(newIdentities)
                
                // 현재 보유중인 아이덴티티들 업데이트
                self.currentVideoIdentities = Set(identities)
                
            case .failure(let failure):
                
                printIfDebug("‼️비디오 코드 불러오기 실패: \(failure.localizedDescription)")
            }
        }
    }
}
