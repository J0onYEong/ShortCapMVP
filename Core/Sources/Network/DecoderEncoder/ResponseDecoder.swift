import Foundation

public protocol ResponseDecoder {
    
    func decode<T: Decodable>(data: Data) throws -> T
}

public class JSONResponseDecoder: ResponseDecoder {
    
    private let decoder = JSONDecoder()
    
    public init() { }
    
    public func decode<T>(data: Data) throws -> T where T : Decodable {
        
        try decoder.decode(T.self, from: data)
    }
}
