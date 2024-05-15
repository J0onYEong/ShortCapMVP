import Foundation

extension Notification.Name {
    
    static let mainCategoryIsChanged: Self = .init("mainCategoryIsChanged")
}

extension Notification {
    
    subscript<T>(_ key: NotificationUserInfoKey) -> T? { self.userInfo?[key.rawValue] as? T }
}

extension NotificationCenter {
    
    func post(name: Notification.Name, object: Any? = nil, userInfo: [NotificationUserInfoKey: Any] = [:]) {
        
        var dict: [String: Any] = [:]
        
        userInfo.forEach { (key, value) in dict[key.rawValue] = value }
        
        self.post(name: name, object: nil, userInfo: dict)
    }
}

enum NotificationUserInfoKey: String, Hashable {
    
    case videoFilter = "videoFilter"
}

