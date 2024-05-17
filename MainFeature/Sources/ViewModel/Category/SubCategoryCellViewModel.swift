import Foundation
import RxSwift
import RxCocoa
import Domain

public class SubCategoryCellViewModel {
    
    public let mainCategory: VideoMainCategory
    public let subCategory: VideoSubCategory
    
    public init(mainCategory: VideoMainCategory, subCategory: VideoSubCategory) {
        self.mainCategory = mainCategory
        self.subCategory = subCategory
    }   
}
