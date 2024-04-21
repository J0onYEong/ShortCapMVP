import Foundation

public protocol BodyEncoder {
    
    func encode(_ parameters: [String: Any]) -> Data?
    
}

public class JSONBodyEncoder: BodyEncoder {
    
    public init() { }
    
    public func encode(_ parameters: [String : Any]) -> Data? {
        
        return try? JSONSerialization.data(withJSONObject: parameters)
    }
}
