//
//  SummaryAPI.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/21/24.
//

import Foundation
import Alamofire

enum SummaryAPI: BaseAPI {
    
    static var apiType: APIType = .summary
    
    case excute(url: String)
    case check(videoId: String)
    case data(pk: String)
}

extension SummaryAPI {
    
    public var headers: [String: String]? {
        switch self {
            default: return HeaderType.json.value
        }
    }
    
    // MARK: - Path
    public var path: String {
        switch self {
        case .excute:
            return "initiate"
        case .check(let id):
            return "status/\(id)"
        case .data(let pk):
            return "\(pk)"
        }
    }
    
    // MARK: - Method
    public var method: HTTPMethod {
        switch self {
        case .excute:
            return .post
        case .check:
            return .get
        case .data:
            return .get
        }
    }
    
    // MARK: - Parameters
    internal var bodyParameters: Parameters? {
        var params: Parameters = [:]
        
        if case .excute(let url) = self {
            
            params["url"] = url
        }
        
        return params
    }
    
    internal var parameterEncoding: ParameterEncoding {
        switch self {
        default:
            return JSONEncoding.default
        }
    }
}
