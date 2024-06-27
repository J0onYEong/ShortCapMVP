import Foundation

public protocol GetAuthTokenRepository {
    
    func getCurrentToken() -> AuthToken?
    func getNewToken() async -> AuthToken?
    func reissueToken(current: AuthToken) async -> AuthToken?
}
