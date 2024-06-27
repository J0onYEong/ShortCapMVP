
public protocol FetchThumbNailRepository {
    
    func fetch(videoInfo: VideoInformation) async throws -> VideoThumbNailInformation
}
