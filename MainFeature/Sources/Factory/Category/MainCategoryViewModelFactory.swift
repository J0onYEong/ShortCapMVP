import Foundation
import Domain
import RxRelay

public class VideoMainCategoryViewModelFactory {
    
    private let repository: GetVideoSubCategoryRepository
    private let factory: SubCategoryCellViewModelFactory
    
    public init(getVideoSubCategoryRepository repository: GetVideoSubCategoryRepository, subCategoryCellViewModelFactory factory: SubCategoryCellViewModelFactory) {
        self.repository = repository
        self.factory = factory
    }
    
    func create(
        mainCategory: VideoMainCategory,
        videoList: BehaviorRelay<[VideoCellViewModelInterface]>
    ) -> VideoMainCategoryViewModel {
        
        .init(
            mainCategory: mainCategory,
            videoList: videoList,
            getVideoSubCategoryRepository: repository,
            subCategoryCellViewModelFactory: factory
        )
    }
}
