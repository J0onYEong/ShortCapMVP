import Foundation

// MARK: - 인터페이스들
public protocol DataTransferDispatchQueue {
    func asyncExecute(work: @escaping () -> Void)
}

extension DispatchQueue: DataTransferDispatchQueue {
    public func asyncExecute(work: @escaping () -> Void) {
        async(group: nil, execute: work)
    }
}

public protocol DataTransferService {
    typealias CompletionHandler<T> = (Result<T, DataTransferError>) -> Void
    
    // MARK: - Completion Handler
    @discardableResult
    func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E,
        on queue: DataTransferDispatchQueue,
        completion: @escaping CompletionHandler<T>
    ) -> NetworkCancellable? where E.Response == T
    
    @discardableResult
    func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<T>
    ) -> NetworkCancellable? where E.Response == T

    @discardableResult
    func request<E: ResponseRequestable>(
        with endpoint: E,
        on queue: DataTransferDispatchQueue,
        completion: @escaping CompletionHandler<Void>
    ) -> NetworkCancellable? where E.Response == Void
    
    @discardableResult
    func request<E: ResponseRequestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<Void>
    ) -> NetworkCancellable? where E.Response == Void
    
    // MARK: - Swift Concurrency
    func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E
    ) async throws -> T where E.Response == T
}

public protocol DataTransferErrorResolver {
    func resolve(error: NetworkError) -> Error
}

public protocol DataTransferErrorLogger {
    func log(error: Error)
}



// MARK: - ImplS

public final class DefaultDataTransferService {
    
    private let networkService: NetworkService
    private let errorResolver: DataTransferErrorResolver
    private let errorLogger: DataTransferErrorLogger
    
    public init(
        with networkService: NetworkService,
        errorResolver: DataTransferErrorResolver = DefaultDataTransferErrorResolver(),
        errorLogger: DataTransferErrorLogger = DefaultDataTransferErrorLogger()
    ) {
        self.networkService = networkService
        self.errorResolver = errorResolver
        self.errorLogger = errorLogger
    }
}

extension DefaultDataTransferService: DataTransferService {
    
    /// 응답바디 있고, 콜백
    public func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E,
        on queue: DataTransferDispatchQueue,
        completion: @escaping CompletionHandler<T>
    ) -> NetworkCancellable? where E.Response == T {

        networkService.request(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                let result: Result<T, DataTransferError> = self.decode(
                    data: data,
                    decoder: endpoint.responseDecoder
                )
                queue.asyncExecute { completion(result) }
            case .failure(let error):
                self.errorLogger.log(error: error)
                let error = self.resolve(networkError: error)
                queue.asyncExecute { completion(.failure(error)) }
            }
        }
    }
    
    /// 응답바디 있고, 콜백
    public func request<T: Decodable, E: ResponseRequestable>(
        with endpoint: E,
        completion: @escaping CompletionHandler<T>
    ) -> NetworkCancellable? where E.Response == T {
        request(with: endpoint, on: DispatchQueue.main, completion: completion)
    }

    /// 응답바디 없고, 콜백
    public func request<E>(
        with endpoint: E,
        on queue: DataTransferDispatchQueue,
        completion: @escaping CompletionHandler<Void>
    ) -> NetworkCancellable? where E : ResponseRequestable, E.Response == Void {
        networkService.request(endpoint: endpoint) { result in
            switch result {
            case .success:
                queue.asyncExecute { completion(.success(())) }
            case .failure(let error):
                self.errorLogger.log(error: error)
                let error = self.resolve(networkError: error)
                queue.asyncExecute { completion(.failure(error)) }
            }
        }
    }

    /// 응답바디 없고, 콜백
    public func request<E>(
        with endpoint: E,
        completion: @escaping CompletionHandler<Void>
    ) -> NetworkCancellable? where E : ResponseRequestable, E.Response == Void {
        request(with: endpoint, on: DispatchQueue.main, completion: completion)
    }
    
    
    // MARK: - Swift concurrency impl
    /// 응답바디 있고, Async, Await호출
    public func request<T: Decodable, E>(with endpoint: E) async throws -> T where E : ResponseRequestable, E.Response == T {
        
        do {
            
            // NetworkServiceError
            let data = try await networkService.request(endpoint: endpoint)
            
            // DataTransferError
            let decoded: T = try decode(data: data, decoder: endpoint.responseDecoder)
            
            return decoded
            
        } catch {
            
            self.errorLogger.log(error: error)
            
            if let networkError = error as? NetworkError {
                
                // 네트워크 서비스 에러 -> 데이터 트렌스퍼 에러로 리졸브
                throw self.resolve(networkError: networkError)
            }
            
            // 파싱에러
            throw error
        }
    }

    // MARK: - Private
    private func decode<T: Decodable>(
        data: Data?,
        decoder: ResponseDecoder
    ) -> Result<T, DataTransferError> {
        do {
            guard let data = data else { return .failure(.noResponse) }
            let result: T = try decoder.decode(data: data)
            return .success(result)
        } catch {
            
            self.errorLogger.log(error: error)
            return .failure(.parsing(error))
        }
    }
    
    private func decode<T: Decodable>(
        data: Data?,
        decoder: ResponseDecoder
    ) throws -> T {
        
        guard let data = data else { throw DataTransferError.noResponse }
        let result: T = try decoder.decode(data: data)
        
        return result
    }
    
    private func resolve(networkError error: NetworkError) -> DataTransferError {
        
        return .networkFailure(error)
    }
}

// MARK: - Logger
public final class DefaultDataTransferErrorLogger: DataTransferErrorLogger {
    public init() { }
    
    public func log(error: Error) {
        printIfDebug("-------------DataTransferErrorLogger-------------")
        printIfDebug("\(error)")
        printIfDebug("-------------------------------------------------")
    }
}

// MARK: - Error Resolver
public class DefaultDataTransferErrorResolver: DataTransferErrorResolver {
    public init() { }
    public func resolve(error: NetworkError) -> Error {
        return error
    }
}

class RawDataResponseDecoder: ResponseDecoder {
    init() { }
    
    enum CodingKeys: String, CodingKey {
        case `default` = ""
    }
    
    func decode<T: Decodable>(data: Data) throws -> T {
        if T.self is Data.Type, let data = data as? T {
            return data
        } else {
            let context = DecodingError.Context(
                codingPath: [CodingKeys.default],
                debugDescription: "Expected Data type"
            )
            throw Swift.DecodingError.typeMismatch(T.self, context)
        }
    }
}
