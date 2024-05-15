import Foundation
import RxSwift
import RxCocoa
import Domain

public class SubCategoryCellViewModel {
    
    private let mainCategory: VideoMainCategory
    private let subCategory: VideoSubCategory
    private let filteringClosure: (VideoFilter) -> Void
    
    public let videoSubCategoryInformation = PublishRelay<VideoSubCategoryInformation>()
    
    private let disposeBag = DisposeBag()
    
    public init(mainCategory: VideoMainCategory, subCategory: VideoSubCategory, filteringClosure: @escaping (VideoFilter) -> Void) {
        self.mainCategory = mainCategory
        self.subCategory = subCategory
        self.filteringClosure = filteringClosure
        
        setObserver()
    }
    
    private func setObserver() {
        
        NotificationCenter.mainFeature.rx.notification(.videoSubCategoryInformationIsChanged)
            .subscribe(onNext: { notification in
                
                if let videoCategoryInformation: VideoCategoryInformation = notification[.videoSubCategoryInformation] {
                    
                    if let videoSubCategoryInformation = videoCategoryInformation[self.mainCategory.categoryId]?[self.subCategory.categoryId] {
                        
                        self.videoSubCategoryInformation.accept(videoSubCategoryInformation)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
}
