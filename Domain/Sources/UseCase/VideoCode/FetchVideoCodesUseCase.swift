import Foundation

public protocol FetchVideoCodesUseCase {
    
    func execute(completion: @escaping (Result<[VideoCode], Error>) -> Void)
}

public final class DefaultFetchVideoCodesUseCase: FetchVideoCodesUseCase {
    
    let fetchVideoCodeRepository: FetchVideoCodesRepository
    
    public init(fetchVideoCodeRepository: FetchVideoCodesRepository) {
        
        self.fetchVideoCodeRepository = fetchVideoCodeRepository
    }
    
    public func execute(completion: @escaping (Result<[VideoCode], Error>) -> Void) {
        
        fetchVideoCodeRepository.fetch(completion: completion)
    }
}
