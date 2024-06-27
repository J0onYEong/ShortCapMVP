import Foundation
import Core

public protocol NetworkConfigurable {
    
    var baseURL: URL { get }
    var googleApiBaseURL: URL { get }
    var keyForGoogleApi: String { get }
    var baseHeader: [String: String] { get }
}

public class DefaultNetworkConfiguration: NetworkConfigurable {
    
    // MARK: - Shortcap server
    public let baseURL: URL = {
        
        guard let urlString = Bundle.main.infoDictionary?["BASE_URL"] as? String,
              let url = URL(string: urlString) else {
            fatalError("Base url 획득실패")
        }
            
        return url
    }()
    
    // MARK: - Google API
    public let googleApiBaseURL = URL(string: "https://www.googleapis.com")!
    public let keyForGoogleApi: String = {
        
        guard let key = Bundle.main.infoDictionary?["Google_Api_Key"] as? String else {
            fatalError("Google api key 획득실패")
        }
        
        return key
    }()
    
    
    // MARK: - request
    public let baseHeader = [
        "Content-Type" : "application/json"
    ]
}
