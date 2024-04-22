import Foundation

public protocol FetchVideoCodesRepository {
    
    func fetch(completion: @escaping (Result<[VideoCode], Error>) -> Void)
}
