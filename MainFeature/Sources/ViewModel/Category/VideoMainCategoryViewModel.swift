import Foundation
import Domain
import RxSwift
import RxCocoa
import Core

public class VideoMainCategoryViewModel {
    
    private let getVideoSubCategoryRepository: GetVideoSubCategoryRepository
    
    public let subCategoryCellViewModelFactory: SubCategoryCellViewModelFactory
    
    public let category: VideoMainCategory
    
    // (View) 획든한 서브카테고리
    public let subCategories = BehaviorRelay<[VideoSubCategory]>(value: [])
    
    // 선택된 서브카테고리 emit
    public var selectedSubCategory: PublishRelay<VideoSubCategory>?
    
    // 에러 퍼피블리셔(미구현)
    public let errorPublisher = PublishRelay<GetVideoSubCategoryRepositoryError>()
    
    private let disposeBag = DisposeBag()
    
    init(
        getVideoSubCategoryRepository: GetVideoSubCategoryRepository,
        subCategoryCellViewModelFactory: SubCategoryCellViewModelFactory,
        category: VideoMainCategory
    ) {
        self.getVideoSubCategoryRepository = getVideoSubCategoryRepository
        self.subCategoryCellViewModelFactory = subCategoryCellViewModelFactory
        self.category = category
        
        setObserver()
        
        if category != .all { fetchCategories() }
    }
    
    private func setObserver() { }
    
    /// 서브카테고리 정보를 가져옵니다.
    private func fetchCategories()  {
        
        getVideoSubCategoryRepository
            .fetch(mainCategory: category) { [weak self] result in
                
                switch result {
                case .success(let subCategories):
                    
                    printIfDebug("\(self?.category.korName ?? "no self:")  카테고리의 서브카테고리 수: \(subCategories.count)")
                    
                    self?.subCategories.accept(subCategories)
                case .failure(let error):
                    self?.errorPublisher.accept(error)
                }
            }
    }
}

