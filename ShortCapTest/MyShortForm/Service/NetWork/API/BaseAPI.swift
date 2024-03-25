//
//  BaseAPI.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/21/24.
//

import Foundation
import Alamofire

enum APIType {
    
    case summary
}

protocol BaseAPI {
    
    static var apiType: APIType { get set }
    
    var path: String { get }
    var method: HTTPMethod { get }
    var bodyParameters: Parameters? { get }
    var parameterEncoding: ParameterEncoding { get }
}

// 전역변수
extension BaseAPI {
    
    var baseUrl: URL {
        
        var base = Config.Network.base
        
        switch Self.apiType {
        case .summary:
            base += "/api/summaries"
        }
        
        guard let url = URL(string: base) else { fatalError() }
        
        return url
    }
}

// 기본값
extension BaseAPI {
    
    public var headers: [String: String]? {
        return HeaderType.json.value
    }
}

// 헤더
enum HeaderType {
    case json
    
    public var value: [String: String] {
        switch self {
        case .json:
            return ["Content-Type": "application/json"]
        }
    }
}
