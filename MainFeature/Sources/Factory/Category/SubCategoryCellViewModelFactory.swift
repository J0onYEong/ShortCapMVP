import Foundation
import Domain

public class SubCategoryCellViewModelFactory {
    
    public func create(mainCategory: VideoMainCategory, subCategory: VideoSubCategory, filteringClosure: @escaping (VideoFilter) -> Void) -> SubCategoryCellViewModel {
        
        return SubCategoryCellViewModel(
            mainCategory: mainCategory,
            subCategory: subCategory,
            filteringClosure: filteringClosure
        )
    }
}
