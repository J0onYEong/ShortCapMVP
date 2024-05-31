import Foundation
import Domain
import Core
import KeychainAccess

public class DefaultGetAuthTokenRepository: GetAuthTokenRepository {
    
    private static let KAccessToken = "accessToken"
    private static let KRefreshToken = "refreshToken"
    private static let KDeviceIdentifier = "deviceIdentifier"
    
    private let dataTransferService: DataTransferService
    
    public init(dataTransferService: DataTransferService) {
        self.dataTransferService = dataTransferService
    }
    
    private let keyChain: Keychain = {
        
        guard let bundleId = Bundle.main.infoDictionary?["Bundle_id"] as? String,
              let appGroupId = Bundle.main.infoDictionary?["App Group"] as? String else { fatalError() }
        
        return Keychain(service: bundleId, accessGroup: appGroupId)
    }()
    
    public func getCurrentToken() -> Domain.AuthToken? {
                
        if let accessToken = try? keyChain.get(Self.KAccessToken),
           let refreshToken = try? keyChain.get(Self.KRefreshToken) {
            
            APIEndpoints.setToken(
                accessToken: accessToken,
                refreshToken: refreshToken
            )
            
            return .init(accessToken: accessToken, refreshToken: refreshToken)
        }
        
        return nil
    }
    
    public func getNewToken() async -> Domain.AuthToken? {
        
        var deviceId = ""
        
        // 디바이스 아이디가 이미 존재하는 경우, 앱이 설치된적 있는 경우
        if let originalId = try? keyChain.get(Self.KDeviceIdentifier) {
            
            deviceId = originalId
        } else {
        
            deviceId = UUID().uuidString
        }
        
        let dto = DeviceIdentityDTO(imei: deviceId)
        
        let endPoint = APIEndpoints.getNewAuthToken(deviceIdentity: dto)
        
        do {
            let response = try await dataTransferService.request(with: endPoint)
            
            if let newToken = response.data {
                
                printIfDebug("✅ 토큰 발행성공")
                
                let entity = newToken.toEntity()
                
                APIEndpoints.setToken(
                    accessToken: entity.accessToken,
                    refreshToken: entity.refreshToken
                )
                
                try keyChain.set(deviceId, key: Self.KDeviceIdentifier)
                try keyChain.set(entity.accessToken, key: Self.KAccessToken)
                try keyChain.set(entity.refreshToken, key: Self.KRefreshToken)
                
                return entity
            }
            
            printIfDebug("‼️ 토큰 발행오류: 토큰이 도착히지 않음")
            
            return nil
            
        } catch {
            
            printIfDebug("‼️ 토큰 발행/저장오류: \(error.localizedDescription)")
            
            return nil
        }
    }
    
    public func reissueToken(current: Domain.AuthToken) async -> Domain.AuthToken? {
        
        let dto = AuthTokenDTO(
            accessToken: current.accessToken,
            refreshToken: current.refreshToken
        )
        
        let endPoint = APIEndpoints.reissueAuthToken(prevToken: dto)
        
        do {
            
            let response = try await dataTransferService.request(with: endPoint)
            
            if let newToken = response.data {
                
                printIfDebug("✅ 토큰 '재'발행성공")
                
                let entity = newToken.toEntity()
                
                APIEndpoints.setToken(
                    accessToken: entity.accessToken,
                    refreshToken: entity.refreshToken
                )
                
                try keyChain.set(entity.accessToken, key: Self.KAccessToken)
                try keyChain.set(entity.refreshToken, key: Self.KRefreshToken)
                
                return entity
            }
            
            printIfDebug("‼️ 토큰 발행오류: 토큰이 도착히지 않음")
            
            return nil
            
        } catch {
            
            printIfDebug("‼️ 토큰 '재'발행/저장오류: \(error.localizedDescription)")
            
            return nil
        }
    }
}
