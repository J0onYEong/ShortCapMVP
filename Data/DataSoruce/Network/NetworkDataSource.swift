import Foundation
import Alamofire
import JunimoFire

final class DefaultNetworkDataSource: NetworkDataSource {
    
    private let configuration: NetworkConfigurable
    private let credential: AuthCrendentialable
    
    init(
        configuration: NetworkConfigurable,
        credential: AuthCrendentialable
    ) {
        self.configuration = configuration
        self.credential = credential
    }
}

public typealias NetworkWithShortcap = (network: NetworkDataSource, api: ShortcapAPI)

open class NetworkDataSource {
    
    /// 인 메모리 데이터 요청입니다.
    func request<R: RequestConvertible>(
        requestConvertible: R,
        completion: @escaping (Result<R.Response, Error>) -> Void) {
            
            do {
                
                let request = try requestConvertible.endPoint.toRequest()
                
                AF
                    .request(request, interceptor: requestConvertible.afInterceptor)
                    .responseDecodable(of: R.Response.self) { response in
                        
                        if let error = response.error {
                            
                            return completion(.failure(error))
                        }
                        
                        if let data = try? response.result.get() {
                            
                            return completion(.success(data))
                        }
                        
                        return completion(.failure(ResponseError.dataIsNotFound))
                    }
                
            } catch {
                
                completion(.failure(error))
            }
    }
    
    func request<R: RequestConvertible>(requestConvertible: R) async throws -> R.Response {
        
        let initialRequest = try requestConvertible.endPoint.toRequest()
        
        var request = initialRequest
        
        let decoded = try await JF
            .request(
                request: request,
                interceptor: requestConvertible.jfInterceptor
            )
            .responseDecodable(type: R.Response.self)
        
        return decoded
    }
}
