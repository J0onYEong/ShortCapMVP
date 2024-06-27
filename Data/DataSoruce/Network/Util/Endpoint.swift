import Foundation
import Alamofire

class Endpoint {
    
    let baseURL: URL
    let path: String
    let method: HTTPMethod
    let headerParameters: [String: String]
    let queryParametersEncodable: Encodable?
    let queryParameters: [String: Any]
    let bodyParametersEncodable: Encodable?
    let bodyParameters: [String: Any]
    
    init(
        baseURL: URL,
        path: String,
        method: HTTPMethod,
        headerParameters: [String : String] = [:],
        queryParametersEncodable: Encodable? = nil,
        queryParameters: [String : Any] = [:],
        bodyParametersEncodable: Encodable? = nil,
        bodyParameters: [String : Any] = [:]
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.headerParameters = headerParameters
        self.queryParametersEncodable = queryParametersEncodable
        self.queryParameters = queryParameters
        self.bodyParametersEncodable = bodyParametersEncodable
        self.bodyParameters = bodyParameters
    }
}

extension Endpoint {
    
    /// End point를 URLRequest로 변경합니다.
    func toRequest() throws -> URLRequest {
        
        let url = try url()
        
        var urlRequest = URLRequest(url: url)
        
        var allHeaders: [String: String] = [:]
        
        headerParameters.forEach { allHeaders.updateValue($1, forKey: $0) }

        let bodyParameters = try bodyParametersEncodable?.toDictionary() ?? self.bodyParameters
        
        if !bodyParameters.isEmpty {
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: bodyParameters)
        }
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = allHeaders
        
        return urlRequest
    }
    
    /// End point를 URLRequest로 변경합니다.
    private func url() throws -> URL {
        
        let urlPath = path.trimmingCharacters(in: ["/"])
        
        let urlWithPath = urlPath.isEmpty ? baseURL : baseURL.appending(path: urlPath)
        
        guard var urlComponents = URLComponents(string: urlWithPath.absoluteString) else { throw RequestGenerationError.worngPathForm }
        
        var queryItems: [URLQueryItem] = []
        
        let queryParameters = try? queryParametersEncodable?.toDictionary() ?? self.queryParameters
        
        queryParameters?.forEach {
            queryItems.append(URLQueryItem(name: $0.key, value: "\($0.value)"))
        }
        
        urlComponents.queryItems = queryItems.isEmpty ? nil : queryItems
        
        guard let finalUrl = urlComponents.url else { throw RequestGenerationError.addQueryParametersFailure }
        
        return finalUrl
    }
}


fileprivate extension Encodable {
    func toDictionary() throws -> [String: Any]? {
        let data = try JSONEncoder().encode(self)
        let jsonData = try JSONSerialization.jsonObject(with: data)
        return jsonData as? [String : Any]
    }
}
