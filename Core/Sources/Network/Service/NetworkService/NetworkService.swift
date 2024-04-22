import Foundation

public protocol NetworkCancellable {
    func cancel()
}

// MARK: - Network Service
public protocol NetworkService {
    typealias CompletionHandler = (Result<Data?, NetworkError>) -> Void
    
    func request(endpoint: Requestable, completion: @escaping CompletionHandler) -> NetworkCancellable?
    func request(endpoint: Requestable) async throws -> Data
}

public class DefaultNetworkService {
    
    private let config: NetworkConfigurable
    private let sessionManager: NetworkSessionManager
    private let logger: NetworkErrorLogger
    
    public init(
        config: NetworkConfigurable = ApiDataNetworkConfig.default,
        sessionManager: NetworkSessionManager = DefaultNetworkSessionManager(),
        networkLogger: NetworkErrorLogger = DefaultNetworkErrorLogger()
    ) {
        self.config = config
        self.sessionManager = sessionManager
        self.logger = networkLogger
    }
    
    func request(request: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancellable {
        
        let sessionDataTask = sessionManager.request(request) { data, response, error in
            
            if let requestError = error {
                var error: NetworkError
                if let response = response as? HTTPURLResponse {
                    error = .error(statusCode: response.statusCode, data: data)
                } else {
                    error = self.resolve(error: requestError)
                }
                
                self.logger.log(error: error)
                completion(.failure(error))
            } else {
                
                self.logger.log(responseData: data, response: response)
                completion(.success(data))
            }
        }
        
        logger.log(request: request)
        
        return sessionDataTask
    }
    
    func request(request: URLRequest) async throws -> Data {
        
        let (data, response) = try await sessionManager.request(request)
        
        self.logger.log(responseData: data, response: response)
        
        return data
    }
    
    private func resolve(error: Error) -> NetworkError {
        let code = URLError.Code(rawValue: (error as NSError).code)
        switch code {
        case .notConnectedToInternet: return .notConnected
        case .cancelled: return .cancelled
        default: return .generic(error)
        }
    }
}

extension DefaultNetworkService: NetworkService {
    
    public func request(endpoint: Requestable, completion: @escaping CompletionHandler) -> NetworkCancellable? {
        
        do {
            
            let urlRequest = try endpoint.urlRequest(with: config)
            
            return request(request: urlRequest, completion: completion)
            
        } catch {
            
            completion(.failure(.urlGeneration))
            
            return nil
        }
    }
    
    public func request(endpoint: Requestable) async throws -> Data {
        
        guard let urlRequest = try? endpoint.urlRequest(with: config) else { throw NetworkError.urlGeneration }
        
        return try await request(request: urlRequest)
    }
}
