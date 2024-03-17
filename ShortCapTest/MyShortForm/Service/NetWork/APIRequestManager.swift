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
        
        // Data transfer
        request.headers = [
            "Content-Type" : "application/json",
        ]
        
        // Auth
        
        return request
    }
    
    func requestStartingSummary(vidoeUrl: String) async throws -> String {
        
        let url = getApiUrl(.startSummary)
        
        var request = getReqeust(url: url, method: .post)

        let jsonObject: [String: Any] = [
            "url": vidoeUrl
        ]
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: jsonObject)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        let httpResponse = response as! HTTPURLResponse
        
        if !(200..<300).contains(httpResponse.statusCode) {
            
            throw APIRequestError.statusCodeFailure(code: httpResponse.statusCode)
        }
        
        guard let decoded = try? JSONDecoder().decode(DefaultResponseDto<SFUuidModel>.self, from: data) else {
            
            print(String(data: data, encoding: .utf8) ?? "Summary Start Request")
            
            throw APIRequestError.decodingFailure
        }
        
        return decoded.data!.uuid
    }
    
    /// 요약 상태를 확인하는 매서드
    /// 요약중일 경우 재귀호출을 통해 성공, 실패할 때까지 요청을 보낸다.
    func requestSummaryState(uuid: String, completion: @escaping (Result<SummaryContentModel, APIRequestError>) -> Void) {
        
        let url = getApiUrl(.checkSummary)
        
        let urlWithUuid = url.appendingPathComponent(uuid)
        
        let request = getReqeust(url: urlWithUuid, method: .get)
        
        AF
            .request(request)
            .validate(statusCode: 200..<300)
            .response(queue: .global()) { response in
                
                switch response.result {
                case .success(let success):
                    
                    // 응답이 잘들어왔고, 디코딩 가는한 지 확인
                    guard let data = success, let decoded = try? JSONDecoder().decode(DefaultResponseDto<SummaryContentDto>.self, from: data) else {
                        
                        if let data = success {
                            
                            print(String(data: data, encoding: .utf8) ?? "Summary Check Failed")
                        }
                        
                        return completion(.failure(APIRequestError.decodingFailure))
                    }
                    
                    // TODO: 이후 확인 url과 데이터를 가져오는 url을 분리할 예정
                    
                    // 성공여부에 따라 요청을 다시보낼 것인지 확인
                    if decoded.result == "success", let dto = decoded.data {
                        
                        let model = SummaryContentModel(content: dto)
                        
                        completion(.success(model))
                    } else {
                        
                        DispatchQueue.global().asyncAfter(deadline: .now()+0.5) {
                            
                            self.requestSummaryState(uuid: uuid, completion: completion)
                        }
                    }
                    
                case .failure(let error):
                    
                    // 요청자체가 실패한 경우
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
