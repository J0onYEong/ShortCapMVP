import Foundation

public protocol FetchVideoCodesRepository {
    
    func fetch(completion: @escaping (Result<[String], Error>) -> Void)
}
