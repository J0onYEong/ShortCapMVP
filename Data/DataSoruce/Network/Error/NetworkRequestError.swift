import Foundation


// MARK: - Request생성 오류
enum RequestGenerationError: Error {
    
    case worngPathForm
    case addQueryParametersFailure
    case crendentialIsNotAvailable
}


// MARK: - Response
enum ResponseError: Error {
    
    case dataIsNotFound
}


// MARK: - Retrier
enum RetryError: Error {
    
    case previousTokenIsNotFound
}
