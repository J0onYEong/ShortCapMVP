import Foundation
import Domain
import RxSwift
import RxCocoa

public extension Notification.Name {
    
    static let mainCategoryIsChanged: Self = .init("mainCategoryIsChanged")
    static let videoSubCategoryInformationIsChanged: Self = .init("videoSubCategoryInformationIsChanged")
    static let videoSubCategoryClicked: Self = .init("videoSubCategoryClicked")
}

public extension Notification {
    
    subscript<T>(_ key: NotificationUserInfoKey) -> T? { self.userInfo?[key.rawValue] as? T }
}

public extension NotificationCenter {
    
    static let mainFeature = NotificationCenter()
    
    func post(name: Notification.Name, object: Any? = nil, userInfo: [NotificationUserInfoKey: Any] = [:]) {
        
        var dict: [String: Any] = [:]
        
        userInfo.forEach { (key, value) in dict[key.rawValue] = value }
        
        self.post(name: name, object: nil, userInfo: dict)
    }
}

public extension NotificationCenter {
    
    static let globalDisposeBag = DisposeBag()
    
    static let videoCategoryInformation: BehaviorRelay<VideoCategoryInformation> = {
        
        let relay = BehaviorRelay<VideoCategoryInformation>(value: [:])
        
        return relay
    }()
}

public enum NotificationUserInfoKey: String, Hashable {
    
    case videoFilter = "videoFilter"
    case videoSubCategoryInformation = "videoSubCategoryInformation"
}

public typealias VideoCategoryInformation = [Int: [Int: VideoSubCategoryInformation]]
