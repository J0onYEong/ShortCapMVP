import Foundation

// MARK: - SessionManager
public protocol NetworkSessionManager {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    typealias CompletionTuple = (Data, URLResponse)
    
    func request(_ request: URLRequest,
                 completion: @escaping CompletionHandler) -> NetworkCancellable
    
    func request(_ request: URLRequest) async throws -> CompletionTuple
}

extension URLSessionDataTask: NetworkCancellable { }

public final class DefaultNetworkSessionManager: NetworkSessionManager {
    
    public init() { }
    
    /// 콜백 요청
    public func request(_ request: URLRequest, completion: @escaping CompletionHandler) -> NetworkCancellable {
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: completion)
        task.resume()
        return task
    }
    
    /// Async/Await 요청
    public func request(_ request: URLRequest) async throws -> CompletionTuple {
        
        return try await URLSession.shared.data(for: request)
    }
}
