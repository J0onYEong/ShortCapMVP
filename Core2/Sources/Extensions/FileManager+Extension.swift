import Foundation

public extension FileManager {
    
    static let sharedPath: URL = {
        
        guard let path = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.shortcap") else {
            fatalError()
        }
        
        return path
    }()
}
