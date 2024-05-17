import Foundation
import Domain

public class VideoMainCategoryViewModelFactory {
    
    private let repository: GetVideoSubCategoryRepository
    private let factory: SubCategoryCellViewModelFactory
    
    public init(getVideoSubCategoryRepository repository: GetVideoSubCategoryRepository, subCategoryCellViewModelFactory factory: SubCategoryCellViewModelFactory) {
        self.repository = repository
        self.factory = factory
    }
    
    func create(category: VideoMainCategory) -> VideoMainCategoryViewModel {
        
        return .init(
            getVideoSubCategoryRepository: repository,
            subCategoryCellViewModelFactory: factory,
            category: category
        )
    }
}
