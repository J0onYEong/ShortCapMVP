import Foundation

public protocol NetworkConfigurable {
    var baseURL: URL { get }
    var headers: [String: String] { get }
    var queryParameters: [String: String] { get }
}

public struct ApiDataNetworkConfig: NetworkConfigurable {
    public let baseURL: URL
    public let headers: [String: String]
    public let queryParameters: [String: String]
    
    public static let `default`: Self = {
            
        guard let baseUrlString = Bundle.main.infoDictionary?["BASE_URL"] as? String,
              let url = URL(string: baseUrlString) else { fatalError() }
        
        let headers = [
            "Content-Type" : "application/json"
        ]
        
        return .init(baseURL: url, headers: headers)
        
    }()
    
    public static let googleApi: Self = {
        
        guard let url = URL(string: "https://www.googleapis.com") else { fatalError() }
        
        return .init(baseURL: url)
    }()
    
    public init(
        baseURL: URL,
        headers: [String: String] = [:],
        queryParameters: [String: String] = [:]
     ) {
        self.baseURL = baseURL
        self.headers = headers
        self.queryParameters = queryParameters
    }
}
