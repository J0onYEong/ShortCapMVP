import Foundation
import Domain
import RxSwift
import RxRelay
import Core

public class MainViewModel {
    
    // 카테고리 작업
    private let getVideoMainCategoryRepository: GetVideoMainCategoryRepository
    public let videoMainCategoryViewModelFactory: VideoMainCategoryViewModelFactory
    // Factory
    public let mainCategoryViewControllerFactory: MainCategoryViewControllerFactory
    
    // (View) Observable
    public let mainCategories = PublishRelay<[VideoMainCategory]>()
    public var fetchedMainCategories: [VideoMainCategory] = []
    public let mainCategoryViewModels = PublishRelay<[VideoMainCategoryViewModel]>()
     
    // 선택된 메인카테고리, 서브카테고리
    public let selectedMainCategoryIndex = BehaviorRelay<Int>(value: 0)
    public let selectedSubCategory = PublishRelay<VideoSubCategory>()
    
    public init(
        getVideoMainCategoryRepository: GetVideoMainCategoryRepository,
        videoMainCategoryViewModelFactory: VideoMainCategoryViewModelFactory,
        mainCategoryViewControllerFactory: MainCategoryViewControllerFactory
    ) {
        self.getVideoMainCategoryRepository = getVideoMainCategoryRepository
        self.videoMainCategoryViewModelFactory = videoMainCategoryViewModelFactory
        self.mainCategoryViewControllerFactory = mainCategoryViewControllerFactory
        
        setObserver()
    }
    
    private let disposeBag = DisposeBag()
    
    private func setObserver() {
        
       
    }
    
    /// 메인 카테고리 정보를 가져옵니다.
    public func fetchCategories() {
        
        getVideoMainCategoryRepository.fetch { result in
            
            switch result {
            case .success(let categories):
                
                printIfDebug("✅가져온 메인카테고리 \(categories.count)개")
                
                self.fetchedMainCategories = categories
                
                self.mainCategories.accept(categories)
                
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
    
    /// 비디오를 필터링하는 옵저버블입니다.
    public func getVideoFilterObservable() -> Observable<VideoFilter> {
        
        Observable
            .combineLatest(selectedMainCategoryIndex, selectedSubCategory)
            .map { (mainCategory, subCategory) in
                
                
                return .all
            }
    }
}

