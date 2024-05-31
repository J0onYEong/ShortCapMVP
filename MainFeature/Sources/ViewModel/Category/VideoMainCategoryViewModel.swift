import Foundation
import Domain
import RxSwift
import RxCocoa
import Core

public class VideoMainCategoryViewModel {
    
    private let getVideoSubCategoryRepository: GetVideoSubCategoryRepository
    
    public let subCategoryCellViewModelFactory: SubCategoryCellViewModelFactory
    
    public let mainCategory: VideoMainCategory
    
    // (View) 획든한 서브카테고리
    public let subCategories = BehaviorRelay<[VideoSubCategory]>(value: [])
    
    // 선택된 서브카테고리 emit
    public var selectedSubCategory = PublishRelay<VideoSubCategory>()
    
    // 비디오 리스트
    private var videoList: BehaviorRelay<[VideoCellViewModelInterface]>
    
    private let errorPublisher = PublishRelay<Error>()
    
    private let disposeBag = DisposeBag()
    
    init(
        mainCategory: VideoMainCategory,
        videoList: BehaviorRelay<[VideoCellViewModelInterface]>,
        getVideoSubCategoryRepository: GetVideoSubCategoryRepository,
        subCategoryCellViewModelFactory: SubCategoryCellViewModelFactory
    ) {
        self.mainCategory = mainCategory
        self.videoList = videoList
        self.getVideoSubCategoryRepository = getVideoSubCategoryRepository
        self.subCategoryCellViewModelFactory = subCategoryCellViewModelFactory
        
        if mainCategory == .all { fatalError() }
        
        fetchCategories()
    }
    
    public func getFilteredVideoList() -> Observable<[VideoCellViewModelInterface]> {
        
        return Observable.combineLatest(
            videoList,
            selectedSubCategory
        )
        .map { [weak self] (videoList, subCategory) in
            
            guard self != nil else { return [] }
            
            let mainCategoryId = self!.mainCategory.categoryId
            let subCategoryId = subCategory.categoryId
            
            return videoList.filter { viewModel in
                
                let videoDetail = viewModel.detail!
                
                return videoDetail.mainCategoryId == mainCategoryId && videoDetail.subCategoryId == subCategoryId
            }
        }
    }
    
    /// 서브카테고리 정보를 가져옵니다.
    private func fetchCategories()  {
        
        getVideoSubCategoryRepository
            .fetch(mainCategory: mainCategory) { [unowned self] result in
                
                switch result {
                case .success(let subCategories):
                    
                    printIfDebug("\(self.mainCategory.korName)  카테고리의 서브카테고리 수: \(subCategories.count)")
                    
                    self.subCategories.accept(subCategories)
                case .failure(let error):
                    self.errorPublisher.accept(error)
                }
            }
    }
}

