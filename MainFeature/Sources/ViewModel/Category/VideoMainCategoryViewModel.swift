import Foundation
import Domain
import RxSwift
import RxCocoa

public class VideoMainCategoryViewModel {
    
    private let getVideoSubCategoryRepository: GetVideoSubCategoryRepository
    
    public let category: VideoMainCategory
    
    private let filterClosure: (VideoFilter) -> Void
    
    public let subCategories = BehaviorRelay<[VideoSubCategory]>(value: [])
    
    public let errorPublisher = PublishRelay<GetVideoSubCategoryRepositoryError>()
    
    private let disposeBag = DisposeBag()
    
    init(
        getVideoSubCategoryRepository: GetVideoSubCategoryRepository,
        category: VideoMainCategory,
        filterClosure: @escaping (VideoFilter) -> Void
    ) {
        self.getVideoSubCategoryRepository = getVideoSubCategoryRepository
        self.category = category
        self.filterClosure = filterClosure
        
        setObserver()
        
        fetchCategories()
    }
    
    private func setObserver() {
        
        // TODO: 컬렉션뷰의 셀 생성
    }
    
    /// 서브카테고리 정보를 가져옵니다.
    private func fetchCategories()  {
        
        getVideoSubCategoryRepository
            .fetch(mainCategory: category) { [weak self] result in
                
                switch result {
                case .success(let subCategories):
                    self?.subCategories.accept(subCategories)
                case .failure(let error):
                    self?.errorPublisher.accept(error)
                }
            }
    }
}

