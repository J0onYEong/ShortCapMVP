import Foundation

public protocol VideoCodeRepositoryInterface {
    
    func save(code: String)
    func get() -> [SummaryIntiationEntitiy]
}
