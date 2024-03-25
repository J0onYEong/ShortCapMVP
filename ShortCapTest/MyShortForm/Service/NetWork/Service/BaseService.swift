//
//  BaseService.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/21/24.
//

import Foundation
import Alamofire
import Combine

class BaseService<Target: BaseAPI> {
    
    typealias API = Target
    
}

extension BaseService {
    
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
}
