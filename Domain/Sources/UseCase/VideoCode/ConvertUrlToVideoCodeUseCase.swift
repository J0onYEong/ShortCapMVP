import Foundation

public protocol ConvertUrlToVideoCodeUseCase {
    
    func execute(
        url: String
    ) async throws -> String
}

public final class DefaultConvertUrlToVideoCodeUseCase: ConvertUrlToVideoCodeUseCase {
    
    let convertUrlRepository: ConvertUrlRepository
    
    public init(convertUrlRepository: ConvertUrlRepository) {
        self.convertUrlRepository = convertUrlRepository
    }
    
    public func execute(url: String) async throws -> String {
        
        do {
            
            let videoCode = try await convertUrlRepository.convert(urlString: url)
            
            return videoCode
            
        } catch {
            
            throw error
        }
    }
}
