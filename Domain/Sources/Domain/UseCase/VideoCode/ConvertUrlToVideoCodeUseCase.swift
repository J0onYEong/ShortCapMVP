import Foundation

public protocol ConvertUrlToVideoCodeUseCase {
    
    func execute(
        url: String
    ) async throws -> VideoCode
}

public final class DefaultConvertUrlToVideoCodeUseCase: ConvertUrlToVideoCodeUseCase {
    
    public func execute(url: String) async throws -> VideoCode {
        
        
    }
}
