import Domain
import Core

public class DefaultThumbNailRepository: FetchThumbNailRepository {
    
    private let networkService: NetworkService
    
    public init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    public func fetch(videoInfo: VideoInformation) async throws -> VideoThumbNailInformation {
        
        // 썸네일 획득
        
        return .mock
    }
}

