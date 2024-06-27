import Foundation

struct ResponseDTOWrapper<T: Decodable>: Decodable {
    
    var result: String?
    var message: String?
    var data: T
}
