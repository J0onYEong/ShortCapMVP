import Foundation
import Domain

extension Notification.Name {
    
    static let mainCategoryIsChanged: Self = .init("mainCategoryIsChanged")
    static let videoSubCategoryInformationIsChanged: Self = .init("videoSubCategoryInformationIsChanged")
}

extension Notification {
    
    subscript<T>(_ key: NotificationUserInfoKey) -> T? { self.userInfo?[key.rawValue] as? T }
}

extension NotificationCenter {
    
    static let mainFeature = NotificationCenter()
    
    func post(name: Notification.Name, object: Any? = nil, userInfo: [NotificationUserInfoKey: Any] = [:]) {
        
        var dict: [String: Any] = [:]
        
        userInfo.forEach { (key, value) in dict[key.rawValue] = value }
        
        self.post(name: name, object: nil, userInfo: dict)
    }
}

enum NotificationUserInfoKey: String, Hashable {
    
    case videoFilter = "videoFilter"
    case videoSubCategoryInformation = "videoSubCategoryInformation"
}

typealias VideoCategoryInformation = [Int: [Int: VideoSubCategoryInformation]]
