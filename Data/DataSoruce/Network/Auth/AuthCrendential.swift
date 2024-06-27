import Foundation
import KeychainAccess

public protocol AuthCrendentialable: AnyObject {
    
    var devideIdentifier: String { get }
    var accessToken: String? { get }
    var refreshToken: String? { get }
    func renewalTokens(accessToken: String, refreshToken: String)
}

public class ShortcapAuthenticationCredential: AuthCrendentialable {
    
    internal init() { }
    
    public typealias Token = String
    public typealias DeviceIdentifier = String
    
    // MARK: - KeyChain
    private enum Key {
        static let KAccessToken = "accessToken"
        static let KRefreshToken = "refreshToken"
        static let KDeviceIdentifier = "deviceIdentifier"
    }
    
    private let keyChain: Keychain = {
        
        guard let bundleId = Bundle.main.infoDictionary?["BUNDLE_ID"] as? String,
              let appGroupId = Bundle.main.infoDictionary?["APP_GROUP"] as? String else { fatalError() }
        
        return Keychain(service: bundleId, accessGroup: appGroupId)
    }()
    
    // MARK: - Device id
    lazy public private(set) var devideIdentifier: DeviceIdentifier = {
        if let id = try? keyChain.get(Key.KDeviceIdentifier) { return id }
        if let id = UserDefaults.standard.string(forKey: Key.KDeviceIdentifier) { return id }
        
        let id = UUID()
        do {
            try keyChain.set(id.uuidString, key: Key.KDeviceIdentifier)
        } catch {
            UserDefaults.standard.setValue(id.uuidString, forKey: Key.KDeviceIdentifier)
        }
        
        return id.uuidString
    }()
    
    // MARK: - Access token & Refresh token
    lazy public private(set) var accessToken: Token? = {
        try? keyChain.get(Key.KAccessToken)
    }()
    lazy public private(set) var refreshToken: Token? = {
        try? keyChain.get(Key.KRefreshToken)
    }()
    
    public func renewalTokens(accessToken: Token, refreshToken: Token) {
        
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        
        do {
            try keyChain.set(accessToken, key: Key.KAccessToken)
            try keyChain.set(refreshToken, key: Key.KRefreshToken)
        } catch {
            
            // 저장할 수 없는 경우 키값을 삭제, 키값이 없는 경우가 아니라면 삭제
            try? keyChain.remove(Key.KAccessToken)
            try? keyChain.remove(Key.KRefreshToken)
        }
    }
}
