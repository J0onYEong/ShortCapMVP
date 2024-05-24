import Foundation
import Domain
import RxSwift
import RxRelay
import Core

public class MainViewModel {
    
    // 카테고리 작업
    private let getVideoMainCategoryRepository: GetVideoMainCategoryRepository
    private let videoMainCategoryViewModelFactory: VideoMainCategoryViewModelFactory
    // Factory
    public let mainCategoryViewControllerFactory: MainCategoryViewControllerFactory
    
    // (View) Observable
    public let mainCategories = BehaviorRelay<[VideoMainCategory]>(value: [])
    public let mainCategoryViewModels = BehaviorRelay<[VideoMainCategoryViewModel]>(value: [])
     
    // 선택된 메인카테고리, 서브카테고리
    public let selectedMainCategory = BehaviorRelay<VideoMainCategory>(value: .all)
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
        
        fetchCategories()
    }
    
    private let disposeBag = DisposeBag()
    
    private func setObserver() {
        
        // MainCategory -> ViewModel
        mainCategories
            .map { [weak self] (items: [VideoMainCategory]) in
                
                items.compactMap { mainCategory in
                    
                    let mainCategoryViewModel = self?.videoMainCategoryViewModelFactory.create(category: mainCategory)
                    
                    mainCategoryViewModel?.selectedSubCategory = self?.selectedSubCategory
                    
                    return mainCategoryViewModel
                }
            }
            .subscribe(onNext: { [weak self] in
                
                self?.mainCategoryViewModels.accept($0)
            })
            .disposed(by: disposeBag)
    }
    
    /// 메인 카테고리 정보를 가져옵니다.
    private func fetchCategories() {
        
        getVideoMainCategoryRepository.fetch { result in
            
            switch result {
            case .success(let categories):
                
                printIfDebug("✅가져온 메인카테고리 \(categories.count)개")
                
                self.mainCategories.accept(categories)
                
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
    
    /// 비디오를 필터링하는 옵저버블입니다.
    public func getVideoFilterObservable() -> Observable<VideoFilter> {
        
        Observable
            .combineLatest(selectedMainCategory, selectedSubCategory)
            .map { (mainCategory, subCategory) in
                
                if mainCategory == .all { return .all }
                
                return VideoFilter(
                    mainCategoryId: mainCategory.categoryId,
                    subCategoryId: subCategory.categoryId
                )
            }
    }
}

