import Foundation

extension Notification.Name {
    
    static let mainCategoryIsChanged: Self = .init("mainCategoryIsChanged")
}

extension Notification {
    
    func getUserInfo<T>(key: NotificationUserInfoKey) -> T? {
        
        self.userInfo[key] as? T
    }
}

extension NotificationCenter {
    
    func postWithUserInfo<T>(name: Notification.Name, key: NotificationUserInfoKey, value: T) {
        
        self.post(name: name, object: nil, userInfo: [key : value])
    }
}

enum NotificationUserInfoKey {
    
    static let videoFilter = "videoFilter"
}

