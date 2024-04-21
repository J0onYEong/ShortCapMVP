import Foundation

public enum HTTPMethodType: String {
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
}

public class Endpoint<R>: ResponseRequestable {
    
    public typealias Response = R
    
    public let path: String
    public let method: HTTPMethodType
    public let headerParameters: [String: String]
    public let queryParametersEncodable: Encodable?
    public let queryParameters: [String: Any]
    public let bodyParametersEncodable: Encodable?
    public let bodyParameters: [String: Any]
    public let bodyEncoder: BodyEncoder
    public let responseDecoder: ResponseDecoder
    
    public init(
        path: String,
        method: HTTPMethodType,
        headerParameters: [String : String] = [:],
        queryParametersEncodable: Encodable? = nil,
        queryParameters: [String : Any] = [:],
        bodyParametersEncodable: Encodable? = nil,
        bodyParameters: [String : Any] = [:],
        bodyEncoder: BodyEncoder = JSONBodyEncoder(),
        responseDecoder: ResponseDecoder = JSONResponseDecoder()
    ) {
        self.path = path
        self.method = method
        self.headerParameters = headerParameters
        self.queryParametersEncodable = queryParametersEncodable
        self.queryParameters = queryParameters
        self.bodyParametersEncodable = bodyParametersEncodable
        self.bodyParameters = bodyParameters
        self.bodyEncoder = bodyEncoder
        self.responseDecoder = responseDecoder
    }
}

public protocol Requestable {
    var path: String { get }
    var method: HTTPMethodType { get }
    var headerParameters: [String: String] { get }
    var queryParametersEncodable: Encodable? { get }
    var queryParameters: [String: Any] { get }
    var bodyParametersEncodable: Encodable? { get }
    var bodyParameters: [String: Any] { get }
    var bodyEncoder: BodyEncoder { get }
    
    func urlRequest(with networkConfig: NetworkConfigurable) throws -> URLRequest
}

public protocol ResponseRequestable: Requestable {
    associatedtype Response
    
    var responseDecoder: ResponseDecoder { get }
}

private extension Encodable {
    func toDictionary() throws -> [String: Any]? {
        let data = try JSONEncoder().encode(self)
        let jsonData = try JSONSerialization.jsonObject(with: data)
        return jsonData as? [String : Any]
    }
}

extension ResponseRequestable {
    
    func url(with config: NetworkConfigurable) throws -> URL {
        
        let urlPath = path.trimmingCharacters(in: ["/"])
        
        let baseURL = config.baseURL
        
        let urlWithPath = urlPath.isEmpty ? baseURL : baseURL.appending(path: urlPath)
        
        guard var urlComponents = URLComponents(string: urlWithPath.absoluteString) else { throw RequestGenerationError.components }
        
        var urlQueryItems: [URLQueryItem] = []
        
        let queryParameters = try queryParametersEncodable?.toDictionary() ?? self.queryParameters
        queryParameters.forEach {
            urlQueryItems.append(URLQueryItem(name: $0.key, value: "\($0.value)"))
        }
        config.queryParameters.forEach {
            urlQueryItems.append(URLQueryItem(name: $0.key, value: $0.value))
        }
        
        urlComponents.queryItems = !urlQueryItems.isEmpty ? urlQueryItems : nil
        
        guard let finalUrl = urlComponents.url else { throw RequestGenerationError.components }
        
        return finalUrl
    }
    
    
    public func urlRequest(with networkConfig: NetworkConfigurable) throws -> URLRequest {
        
        // URL 만들기
        let url = try url(with: networkConfig)
        
        var urlRequest = URLRequest(url: url)
        
        var allHeaders: [String: String] = networkConfig.headers
        
        headerParameters.forEach { allHeaders.updateValue($1, forKey: $0) }

        let bodyParameters = try bodyParametersEncodable?.toDictionary() ?? self.bodyParameters
        
        if !bodyParameters.isEmpty {
            urlRequest.httpBody = bodyEncoder.encode(bodyParameters)
        }
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = allHeaders
        
        return urlRequest
    }
}





