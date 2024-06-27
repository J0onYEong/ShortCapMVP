import Foundation

extension ShortcapAPI {
    
    func fetchYoutubeVideoThumbNail(videoId: String) -> RequestBox<VideoThumbNailDTO> {
        
        let apiKey = configuration.keyForGoogleApi
        
        let endPoint = Endpoint(
            baseURL: configuration.googleApiBaseURL,
            path: "youtube/v3/videos",
            method: .get,
            headerParameters: configuration.baseHeader,
            queryParameters: [
                "part" : "snippet",
                "id" : videoId,
                "key" : apiKey
            ]
        )
        return RequestBox(
            endPoint: endPoint
        )
    }
}
