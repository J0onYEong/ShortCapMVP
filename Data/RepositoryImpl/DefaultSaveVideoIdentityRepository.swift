import Foundation
import Domain
import Core

public final class DefaultSaveVideoIdentityRepository: SaveVideoIdentityRepository {
    
    let storage: VideoIdentityStorage
    
    public init(videoIdentityStorage storage: VideoIdentityStorage) {
        self.storage = storage
    }
    
    public func save(videoIdentity: VideoIdentity, completion: @escaping (Bool) -> Void) {
        
        // VideoIdentity가 이미 존재하는지 확인
        storage.fetch { result in
            
            switch result {
            case .success(let videoIdentities):
                
                let filtered = videoIdentities.filter { $0 == videoIdentity }
                
                // 중복이 없는 경우
                if filtered.isEmpty {
                    
                    self.storage.save(videoIdentity: videoIdentity) { result in
                        
                        switch result {
                        case .success( _ ):
                            
                            completion(true)
                            
                        case .failure(let error):
                            
                            // 코어데이터 에러
                            printIfDebug("‼️비디오 아이덴티티 저장실패: \(error) \n \(error.localizedDescription)")
                            
                            completion(false)
                        }
                    }
                } else {
                    
                    // 이미중복된 코드가 있음으로 저장과정을 생략
                    completion(true)
                }
                
            case .failure(let failure):
                
                printIfDebug("‼️데이터 불러오기 실패: \(failure) \n \(failure.localizedDescription)")
                
                completion(false)
            }
        }
    }
}
