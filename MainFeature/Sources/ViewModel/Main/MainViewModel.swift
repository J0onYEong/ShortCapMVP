import Foundation
import Domain
import RxSwift
import RxRelay
import Core

public class MainViewModel {
    
    // 카테고리 작업
    private let getVideoMainCategoryRepository: GetVideoMainCategoryRepository
    private let videoMainCategoryViewModelFactory: VideoMainCategoryViewModelFactory
    
    public let mainCategories = BehaviorRelay<[VideoMainCategory]>(value: [])
    
    public let mainCategoryViewModels = BehaviorRelay<[VideoMainCategoryViewModel]>(value: [])
     
    public let selectedMainCategory = BehaviorRelay<VideoMainCategory>(value: .all)
    
    // Factory
    public let mainCategoryViewControllerFactory: MainCategoryViewControllerFactory
    
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
                    
                    self?.videoMainCategoryViewModelFactory.create(category: mainCategory)
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
}

