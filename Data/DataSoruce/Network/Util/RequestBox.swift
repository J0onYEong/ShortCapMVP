import Foundation
import Alamofire
import JunimoFire

protocol RequestConvertible {
    associatedtype Response: Decodable
    
    var endPoint: Endpoint { get }
    var afInterceptor: RequestInterceptor? { get }
    var jfInterceptor: JFRequestInterceptor? { get }
}



struct RequestBox<R: Decodable>: RequestConvertible  {
    
    typealias Response = R
    
    let endPoint: Endpoint
    let afInterceptor: RequestInterceptor?
    let jfInterceptor: JFRequestInterceptor?
    
    init(
        endPoint: Endpoint,
        afInterceptor: RequestInterceptor? = nil,
        jfInterceptor: JFRequestInterceptor? = nil
    ) {
        self.endPoint = endPoint
        self.afInterceptor = afInterceptor
        self.jfInterceptor = jfInterceptor
    }
}
