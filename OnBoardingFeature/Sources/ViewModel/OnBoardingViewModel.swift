import Foundation
import Domain

public class OnBoardingViewModel {
    
    let getTokenRepository: GetAuthTokenRepository
    
    public init(getTokenRepository: GetAuthTokenRepository) {
        self.getTokenRepository = getTokenRepository
    }
    
    public func getToken() async -> AuthToken? {
        
        if let token = getTokenRepository.getCurrentToken() {
            
            // 토큰을 무조건 재발행
//            return await getTokenRepository.reissueToken(current: token)
            
            return token
        } else {
            
            return await getTokenRepository.getNewToken()
        }
    }
}
