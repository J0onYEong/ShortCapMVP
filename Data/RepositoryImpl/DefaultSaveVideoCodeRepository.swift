import Foundation
import Domain
import Core

public final class DefaultSaveVideoCodeRepository: SaveVideoCodeRepository {
    
    let storage: VideoCodeStorage
    
    public init(storage: VideoCodeStorage) {
        self.storage = storage
    }
    
    public func save(videoCode: VideoCode, completion: @escaping (VideoCode?) -> Void) {
        
        // 이미 존재하는지 확인
        storage.getResponse { result in
            
            switch result {
            case .success(let localVideoCodeDTOS):
                
                let filtered = localVideoCodeDTOS.filter { localVideoCodeDTO in
                    
                    localVideoCodeDTO.code == videoCode.code
                }
                
                // 중복이 없는 경우
                if filtered.isEmpty {
                    
                    // 엔티티를 DTO로 변경
                    let videoCodeDTO = VideoCodeDTO(code: videoCode.code)
                    
                    self.storage.save(videoCodeDTO: videoCodeDTO) { result in
                        
                        switch result {
                        case .success(let videoCodeDTO):
                            
                            completion(VideoCode(code: videoCodeDTO.code))
                            
                        case .failure(let failure):
                            printIfDebug("‼️비디오 코드 저장실패: \(failure) \n \(failure.localizedDescription)")
                            
                            completion(nil)
                        }
                    }
                } else {
                    
                    // 이미중복된 코드가 있음으로 저장과정을 생략
                    completion(videoCode)
                }
                
            case .failure(let failure):
                
                printIfDebug("‼️데이터 불러오기 실패: \(failure) \n \(failure.localizedDescription)")
                
                completion(nil)
            }
        }
    }
}
