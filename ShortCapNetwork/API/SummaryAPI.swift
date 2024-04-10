import Foundation
import Alamofire

public enum SummaryAPI: BaseAPI {
    
    public static var apiType: APIType = .summary
    
    case excute
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
    public var bodyParameters: Parameters? {
        var params: Parameters = [:]
        
        return params
    }
    
    public var parameterEncoding: ParameterEncoding {
        switch self {
        default:
            return JSONEncoding.default
        }
    }
}
