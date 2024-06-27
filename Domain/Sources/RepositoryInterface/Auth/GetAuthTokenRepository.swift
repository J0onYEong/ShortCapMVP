import Foundation

public protocol GetAuthTokenRepository {
    
    func issueNewToken() async -> AuthToken?
}
