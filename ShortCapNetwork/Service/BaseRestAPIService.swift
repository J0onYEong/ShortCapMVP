import Foundation
import Alamofire
import Combine

public class BaseRestAPIService<Target: BaseAPI> {
    
    public typealias API = Target
}


public enum NetworkError: Error {
    
    case decodingError(decodingType: String, url: String)
    case unExpectedStatus(statusCode: Int)
}

public extension BaseRestAPIService {
    
    func makeRequest<T: Decodable>(_ api: API) -> AnyPublisher<T, Error> {
        
        return Future { promise in
            
            var httpHeaders: HTTPHeaders = .init()
            
            if let headers = api.headers {
                
                for header in headers {
                        
                    httpHeaders.add(HTTPHeader(name: header.key, value: header.value))
                }
            }
            
            let url = api.baseUrl.appendingPathComponent(api.path)
            
            AF.request(
                url,
                method: api.method,
                parameters: [.post, .put].contains(api.method) ? api.bodyParameters : nil,
                encoding: api.parameterEncoding,
                headers: httpHeaders
            )
            .validate(statusCode: 200..<300)
            .responseDecodable(of: T.self) { response in
                
                switch response.result {
                case .success(let success):

                    promise(.success(success))
                case .failure(let failure):
                    
                    promise(.failure(failure))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func makeRequest<T: Decodable>(_ api: API, body: (any Encodable)? = nil) async throws -> T {
        
        var httpHeaders: HTTPHeaders = .init()
        
        if let headers = api.headers {
            
            for header in headers {
                    
                httpHeaders.add(HTTPHeader(name: header.key, value: header.value))
            }
        }
        
        let url = api.baseUrl.appendingPathComponent(api.path)
        
        var request = try URLRequest(url: url, method: api.method)
        
        request.headers = httpHeaders
        
        if let body {
            
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        let statusCode = (response as! HTTPURLResponse).statusCode
        
        if !(200..<300).contains(statusCode) {
            
            throw NetworkError.unExpectedStatus(statusCode: statusCode)
        }
        
        guard let deocded = try? JSONDecoder().decode(T.self, from: data) else {
            
            throw NetworkError.decodingError(decodingType: String(describing: T.self), url: url.absoluteString)
        }
        
        return deocded
    }
}
