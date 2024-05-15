import Foundation
import Domain
import RxSwift
import RxRelay

public class MainViewModel {
    
    // 카테고리 작업
    private let getVideoMainCategoryRepository: GetVideoMainCategoryRepository
    private let videoMainCategoryViewModelFactory: VideoMainCategoryViewModelFactory
    
    public let mainCategories = BehaviorRelay<[VideoMainCategory]>(value: [])
    
    private let videoFilter = BehaviorRelay<VideoFilter>(value: .all)
    
    public let mainCategoryViewModels = BehaviorRelay<[MainCategoryViewModel]>(value: [])
    
    init(
        getVideoMainCategoryRepository: GetVideoMainCategoryRepository,
        videoMainCategoryViewModelFactory: VideoMainCategoryViewModelFactory
    ) {
        self.getVideoMainCategoryRepository = getVideoMainCategoryRepository
        self.videoMainCategoryViewModelFactory = videoMainCategoryViewModelFactory
        
        setObserver()
    }
    private let disposeBag = DisposeBag()
    
    private func setObserver() {
        
        // MainCategory -> ViewModel
        mainCategories
            .map { [weak self] (items: [VideoMainCategory]) in
                
                items.compactMap { mainCategory in
                    
                    self?.videoMainCategoryViewModelFactory.create(category: mainCategory) { [weak self] subCategoryId in
                            
                        let newFiler = VideoFilter(
                            mainCategoryId: mainCategory.categoryId,
                            subCategoryId: subCategoryId
                        )
                        
                        // 이전필터와 값이 다른 경우만 이벤트를 전송합니다.
                        if let prevFilter = self?.videoFilter.value, prevFilter != newFiler {
                            
                            self?.videoFilter.accept(newFiler)
                        }
                    }
                }
            }
            .subscribe(onNext: { [weak self] in
                
                self?.mainCategoryViewModels.accept($0)
            })
            .disposed(by: disposeBag)
        
        
        videoFilter
            .subscribe(onNext: { filter in
                
                NotificationCenter.default.postWithUserInfo(name: .mainCategoryIsChanged, key: .videoFilter, value: filter)
            })
            .disposed(by: disposeBag)
    }
    
    /// 메인 카테고리 정보를 가져옵니다.
    private func fetchCategories() {
        
        getVideoMainCategoryRepository.fetch { result in
            
            switch result {
            case .success(let categories):
                
                self.mainCategories.accept(categories)
                
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
}

