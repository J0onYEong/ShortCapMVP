import Foundation
@testable import Data
import Alamofire

class TestNetworkConfiguration: NetworkConfigurable {
   
    var baseURL: URL = URL(string: "http://15.165.250.47:8080")!
    
    var googleApiBaseURL: URL = URL(string: "https://www.googleapis.com")!
    
    var keyForGoogleApi: String = ""
    
    var baseHeader: [String : String] = ["Content-Type" : "application/json"]
    
}

class TestAuthCredential: AuthCrendentialable {
    
    var devideIdentifier: String = UUID().uuidString
    
    var accessToken: String? { TemporalStore.accessToken }
    
    var refreshToken: String? { TemporalStore.refreshToken }
    
    func renewalTokens(accessToken: String, refreshToken: String) {
        
        TemporalStore.accessToken = accessToken
        TemporalStore.refreshToken = refreshToken
    }
}

enum TemporalStore {
    
    static var accessToken: String?
    static var refreshToken: String?
}
