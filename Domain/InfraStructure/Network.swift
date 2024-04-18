import Foundation

public protocol Cancellable {
    
    func cancel() -> Void
}

public protocol NetworkCancellable {
    
    func cancel() -> Void
}

extension Task: NetworkCancellable {}
extension URLSessionDataTask: NetworkCancellable {}
