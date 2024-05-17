import Foundation
import Domain

public class SubCategoryCellViewModelFactory {
    
    public init() { }
    
    public func create(mainCategory: VideoMainCategory, subCategory: VideoSubCategory) -> SubCategoryCellViewModel {
        
        return SubCategoryCellViewModel(
            mainCategory: mainCategory,
            subCategory: subCategory
        )
    }
}
