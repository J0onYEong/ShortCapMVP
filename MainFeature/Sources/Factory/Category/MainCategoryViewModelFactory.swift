import Foundation
import Domain

public class VideoMainCategoryViewModelFactory {
    
    private let repository: GetVideoSubCategoryRepository
    
    public init(getVideoSubCategoryRepository repository: GetVideoSubCategoryRepository) {
        self.repository = repository
    }
    
    func create(category: VideoMainCategory, filterClosure: @escaping (VideoFilter) -> Void) -> VideoMainCategoryViewModel {
        
        return .init(
            getVideoSubCategoryRepository: repository,
            category: category,
            filterClosure: filterClosure
        )
    }
}
