import Foundation
import Core


// MARK: - Summary
struct APIEndpoints {
    
    /// 비디오 코드를 획득합니다.
    static func getVideoCode(with videoCodeRequestDTO: VideoCodeRequestDTO) -> Endpoint<ResponseDTOWrapper<VideoCodeResponseDTO>> {

        return Endpoint(
            path: "api/summaries/initiate",
            method: .post,
            bodyParametersEncodable: videoCodeRequestDTO
        )
    }
    
    /// 비디오 요약상태를 획득합니다.
    static func getVideoSummaryState(with videoCode: String) -> Endpoint<ResponseDTOWrapper<VideoSummaryStateResponseDTO>> {
        
        return Endpoint(
            path: "api/summaries/status/\(videoCode)",
            method: .get
        )
    }
    
    /// 비디오 요약정보를 가져옵니다.
    static func getVideoDetail(with videoId: Int) -> Endpoint<ResponseDTOWrapper<VideoDetailResponseDTO>> {
        
        return Endpoint(
            path: "api/summaries/\(videoId)",
            method: .get
        )
    }
}


// MARK: - ThumbNail
extension APIEndpoints {
    
    
    static func getYoutubeThumbNail(youtubeVideoId id: String) -> Endpoint<VideoThumbNailDTO> {
        
        guard let apiKey = Bundle.main.infoDictionary?["Google_Api_Key"] else { fatalError() }
        
        return Endpoint(
            path: "youtube/v3/videos",
            method: .get,
            queryParameters: [
                "part" : "snippet",
                "id" : id,
                "key" : apiKey
            ]
        )
    }
}
