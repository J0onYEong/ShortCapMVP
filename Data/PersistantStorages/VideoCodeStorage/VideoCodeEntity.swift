import Foundation

extension VideoCodeEntity {
    
    func toDTO() -> String {
        
        return self.videoCode ?? ""
    }
}
