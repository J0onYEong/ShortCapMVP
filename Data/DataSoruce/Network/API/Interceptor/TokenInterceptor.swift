//
//  TokenIntercepter.swift
//  Data
//
//  Created by 최준영 on 6/23/24.
//

import Foundation
import Alamofire
import JunimoFire

class TokenInterceptor {
    
    let configuration: NetworkConfigurable
    let credential: AuthCrendentialable
    
    public init(configuration: NetworkConfigurable, credential: AuthCrendentialable) {
        self.configuration = configuration
        self.credential = credential
    }
    
    /// 만료된 토큰을 재발행 한다.
    var reissueTokenRequest: RequestBox<ResponseDTOWrapper<AuthTokenDTO>>? {
        
        guard let accessToken = credential.accessToken, let refreshToken = credential.refreshToken else { return nil }
        
        let expiredTokens = AuthTokenDTO(
            accessToken: accessToken,
            refreshToken: refreshToken
        )
        
        let endPoint = Endpoint2(
            baseURL: configuration.baseURL,
            path: "api/auth/reissue",
            method: .post,
            headerParameters: configuration.baseHeader,
            bodyParametersEncodable: expiredTokens
        )
        
        return RequestBox(
            endPoint: endPoint
        )
    }
    
    var afTokenInterceptor: RequestInterceptor {
        
        Interceptor(
            adapter: afTokenAdapter,
            retrier: afTokenRetrier
        )
    }
    
    private var afTokenAdapter: RequestAdapter {
        
        Adapter { [weak credential] request, session, completion in
            
            var modifiedRequest = request
            
            if let accessToken = credential?.accessToken {
                
                let bearerToken = "Bearer \(accessToken)"
                
                modifiedRequest
                    .addValue(bearerToken, forHTTPHeaderField: "Authorization")
                
                completion(.success(modifiedRequest))
                
            }
        }
    }
    
    private var afTokenRetrier: RequestRetrier {
        
            var tokenReissueHandler: RetryHandler = { [weak self, weak credential] request, session, error, completion in
            
            // 토큰이 만료된 경우
            if let httpResponseError = request.response, httpResponseError.statusCode == 401 {
                
                guard let request = try? self?.reissueTokenRequest?.endPoint.toRequest() else { return completion(.doNotRetry) }
                
                session
                    .request(request)
                    .responseDecodable(of: ResponseDTOWrapper<AuthTokenDTO>.self) { [weak credential] response in
                        
                        if let error = response.error {
                            
                            return completion(.doNotRetryWithError(error))
                        }
                        
                        guard let responseData = try? response.result.get().data
                        else {
                            return completion(.doNotRetry)
                        }
                        
                        credential?.renewalTokens(
                            accessToken: responseData.accessToken,
                            refreshToken: responseData.refreshToken
                        )
                        
                        // 토큰 갱신완료
                        completion(.retry)
                    }
            }
        }
        
        return RetryInLimtedCount(maxCount: 1, handler: tokenReissueHandler)
    }
    
    var jfTokenInterceptor: JFRequestInterceptor {
        
        JFInterceptor.interceptor(
            adaper: jfTokenAdapter,
            retrier: jfTokenRetrier
        )
    }
    
    private var jfTokenAdapter: JFAdpater {
        
        JFAdpater(label: "Token adapter") { [weak credential] _, request in
            
            guard let accessToken = credential?.accessToken else { return request }
            
            var adaptedRequest = request
            
            adaptedRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            return adaptedRequest
        }
    }
    
    private var jfTokenRetrier: JFRetrier {
        
        JFRetrier(label: "Token retrier") { [weak self, weak credential] info, request, response, data in
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                
                guard let reissueRequest = try? self?.reissueTokenRequest?.endPoint.toRequest() else { return .doNotRetry }
                
                let reissuedToken = try await JunimoFire.JF
                    .request(request: reissueRequest, interceptor: nil)
                    .responseDecodable(type: ResponseDTOWrapper<AuthTokenDTO>.self)
                
                guard let accessToken = reissuedToken.data?.accessToken,
                      let refreshToken = reissuedToken.data?.refreshToken else { return .finish }
                
                credential?.renewalTokens(accessToken: accessToken, refreshToken: refreshToken)
                
                var adaptedRequest = request
                
                adaptedRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                
                return .retryImediately(request: adaptedRequest)
                
            } else {
                
                return .doNotRetry
            }
        }
    }
}

// MARK: - 토큰 만료시 재발급을 담당하는 Retrier입니다.
class RetryInLimtedCount: RequestRetrier {
    
    let maxCount: Int
    let handler: RetryHandler
    
    private var retryCount = 0
    
    init(maxCount: Int, handler: @escaping RetryHandler) {
        
        self.maxCount = maxCount
        self.handler = handler
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        
        if retryCount < maxCount {
            
            retryCount += 1
            handler(request, session, error, completion)
        } else {
            
            completion(.doNotRetry)
        }
    }
}

