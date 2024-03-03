//
//  APIRequestManager.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/3/24.
//

import Foundation
import Alamofire

class APIRequestManager: APIFetcher {
    
    let baseUrl = URL(string: "http://43.200.209.58:80")!
    
    enum APIType {
        case startSummary
        case checkSummary
    }
    
    func getApiUrl(_ api: APIType) -> URL {
        
        var pathComponent: String!
        
        switch api {
        case .startSummary:
            pathComponent = "summary/initiate"
        case .checkSummary:
            pathComponent = "summary/status"
        default:
            fatalError("unprocessed api")
        }
        
        return baseUrl.appendingPathComponent(pathComponent)
    }
    
    func getReqeust(url: URL, method: HTTPMethod) -> URLRequest {
        
        var request = try! URLRequest(url: url, method: method)
        
        request.headers = [
            "Content-Type" : "application/json",
        ]
        
        // Auth
        
        return request
    }
    
    func requestSFSummary(sFUrl: String) async throws -> String {
        
        let url = getApiUrl(.startSummary)
        
        var request = getReqeust(url: url, method: .post)

        let jsonObject: [String: Any] = [
            "url": sFUrl
        ]
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: jsonObject)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        let httpResponse = response as! HTTPURLResponse
        
        if !(200..<300).contains(httpResponse.statusCode) {
            
            throw APIRequestError.statusCodeFailure(code: httpResponse.statusCode)
        }
        
        guard let decoded = try? JSONDecoder().decode(DefaultResponseModel<SFUuidModel>.self, from: data) else {
            
            print(String(data: data, encoding: .utf8) ?? "Summary Start Request")
            
            throw APIRequestError.decodingFailure
        }
        
        return decoded.data!.uuid
    }
    
    func checkRequest(uuid: String, completion: @escaping (Result<SFModel, APIRequestError>) -> Void) {
        
        let url = getApiUrl(.checkSummary)
        
        let urlWithUuid = url.appendingPathComponent(uuid)
        
        let request = getReqeust(url: urlWithUuid, method: .get)
        
        AF
            .request(request)
            .validate(statusCode: 200..<300)
            .response(queue: .global()) { response in
                
                switch response.result {
                case .success(let success):
                    guard let data = success, let decoded = try? JSONDecoder().decode(DefaultResponseModel<SFModel>.self, from: data) else {
                        
                        if let data = success {
                            
                            print(String(data: data, encoding: .utf8) ?? "Summary Check Failed")
                        }
                        
                        return completion(.failure(APIRequestError.decodingFailure))
                    }
                    
                    if decoded.result == "success", let model = decoded.data {
                        
                        completion(.success(model))
                    } else {
                        
                        DispatchQueue.global().asyncAfter(deadline: .now()+0.5) {
                            
                            self.checkRequest(uuid: uuid, completion: completion)
                        }
                    }
                    
                case .failure(let error):
                    
                    if let statusCode = response.response?.statusCode, !(200..<300).contains(statusCode) {
                        
                        completion(.failure(APIRequestError.statusCodeFailure(code: statusCode)))
                    } else {
                        
                        completion(.failure(APIRequestError.unknownError(description: error.localizedDescription)))
                    }
                }
            }

    }
}

struct SFUuidModel: Decodable {
    
    let uuid: String
}
