import UIKit
import MainFeature
import Domain
import RxCocoa
import RxSwift

class TestVideoListViewModel: VideoListViewModelInterface {
    
    func fetchVideoIdentities() {
        
    }

    static let mockData: [VideoCellViewModelInterface] = {
        
        (1...30).map { _ in TestVideoCellViewModel() }
    }()
    
    let displayingVideoCellViewModel = BehaviorRelay<[VideoCellViewModelInterface]>(value: mockData)
    
    let filterdVideoCellViewModel = BehaviorRelay<[VideoCellViewModelInterface]>(value: [])
    
    private let disposeBag = DisposeBag()
    
    init() {
        
        let filterObservable = NotificationCenter.mainFeature.rx.notification(.videoSubCategoryClicked)
            .map { notification in
                
                guard let videoFilter: VideoFilter = notification[.videoFilter] else { fatalError() }
                
                print("필터링 이벤트 도착\(videoFilter.mainCategoryId) : \(videoFilter.subCategoryId)")
                
                return videoFilter
            }
        
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
}

class TestVideoCellViewModel: VideoCellViewModelInterface {

    var videoIdentity: VideoIdentity = .init(videoCode: "aaaa", originUrl: "bbbb")
    
    var detail: VideoDetail? = {
        
        let mainCategoryId = (0...9).randomElement()!
        let subCategoryId = mockData[mainCategoryId]!
        
        let detail = VideoDetail.mockInstance()
        
        detail.mainCategoryId = mainCategoryId
        detail.subCategoryId = subCategoryId
        
        print("메인: \(detail.mainCategoryId), 서브: \(detail.subCategoryId)")
        
        return detail
    }()
    
    public let detailSubject: ReplaySubject<VideoDetail> = .create(bufferSize: 1)
    public let thumbNailSubject: ReplaySubject<UIImage> = .create(bufferSize: 1)
    
    static let mockData: [Int: Int] = [
        0: 1,
        1: 2,
        2: 3,
        3: 4,
        4: 5,
        5: 0,
        6: 6,
        7: 7,
        8: 8,
        9: 9,
    ]
    
    func fetchDetailAndThumbNail() {
        
        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            
            self.detailSubject
                .onNext(self.detail!)
            
            self.thumbNailSubject
                .onNext(UIImage())
        }
    }
}
