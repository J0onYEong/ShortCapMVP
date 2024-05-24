import Foundation
import Domain
import RxSwift
import RxCocoa

public extension NotificationCenter {
    
    static let videoCategoryMappingResult = BehaviorRelay<VideoCategoryMappingResult>(value: [:])
}

public typealias VideoCategoryMappingResult = [Int: [Int: VideoSubCategoryMappingResult]]
