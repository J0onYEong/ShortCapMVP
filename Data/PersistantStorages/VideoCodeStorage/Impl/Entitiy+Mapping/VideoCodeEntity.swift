import Foundation

extension VideoCodeEntity {
    
    func toDTO() -> VideoCodeDTO {
        
        let dto = VideoCodeDTO(code: self.code ?? "")
        
        return dto
    }
}
