import Foundation
import Core

public protocol NetworkConfigurable {
    
    var baseURL: URL { get }
    var baseHeader: [String: String] { get }
}

public class DefaultNetworkConfiguration: NetworkConfigurable {
    
    public init() { }
    
    // MARK: - Shortcap server
    public let baseURL: URL = {
        
        guard let urlString = Bundle.main.infoDictionary?["BASE_URL"] as? String,
              let url = URL(string: urlString) else {
            fatalError("Base url 획득실패")
        }
            
        return url
    }()
    
    // MARK: - request
    public let baseHeader = [
        "Content-Type" : "application/json"
    ]
}
