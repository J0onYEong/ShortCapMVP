import Foundation
import Domain

struct AuthTokenDTO: Codable {
    
    let accessToken: String
    let refreshToken: String
    
    func toEntity() -> AuthToken {
        .init(accessToken: accessToken, refreshToken: refreshToken)
    }
}

struct DeviceIdentityDTO: Codable {
    let imei: String
}
