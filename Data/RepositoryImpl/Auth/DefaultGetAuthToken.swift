import Foundation
import Domain
import Core
import KeychainAccess

public class DefaultGetAuthTokenRepository: GetAuthTokenRepository {
    
    private static let KAccessToken = "accessToken"
    private static let KRefreshToken = "refreshToken"
    private static let KDeviceIdentifier = "deviceIdentifier"
    
    private let networkService: NetworkService
    private let credential: AuthCrendentialable
    
    public init(networkService: NetworkService, credential: AuthCrendentialable) {
        self.networkService = networkService
        self.credential = credential
    }
    
    public func issueNewToken() async -> Domain.AuthToken? {
        
        var deviceId = credential.devideIdentifier

        let dto = DeviceIdentityDTO(imei: deviceId)
        
        let requestable = networkService.api.issueToken(deviceIdentity: dto)
        
        do {
            let response = try await networkService.network.request(requestConvertible: requestable)
            
            let token = response.data
            printIfDebug("""
                ✅ 토큰 발행성공
                    accessToken: \(token.accessToken)
                    refreshToken: \(token.refreshToken)
            """)
            
            let entity = token.toEntity()
            
            credential.renewalTokens(accessToken: token.accessToken, refreshToken: token.refreshToken)
            
            return entity
            
        } catch {
            
            printIfDebug("‼️ 토큰 오류: \(error.localizedDescription)")
            
            return nil
        }
    }
}
