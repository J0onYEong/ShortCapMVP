import Foundation

public protocol ConvertUrlToVideoCodeUseCase {
    
    func execute(
        url: String
    ) async throws -> VideoCode
}

public final class DefaultConvertUrlToVideoCodeUseCase: ConvertUrlToVideoCodeUseCase {
    
    let convertUrlRepository: ConvertUrlRepository
    
    public init(convertUrlRepository: ConvertUrlRepository) {
        self.convertUrlRepository = convertUrlRepository
    }
    
    public func execute(url: String) async throws -> VideoCode {
        
        try await convertUrlRepository.convert(urlString: url)
    }
}
