import Foundation
import Combine

public final class SummaryRestAPIService: BaseRestAPIService<SummaryAPI> {
    
    private override init() { }
    
    public static let `default` = SummaryRestAPIService()
}
