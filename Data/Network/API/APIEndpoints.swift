import Foundation
import Core

// MARK: - AuthToken
struct APIEndpoints {
    
    static func setToken(
        accessToken: String,
        refreshToken: String
    ) {
        UserData.accessToken = accessToken
        UserData.refreshToken = refreshToken
    }
    
    fileprivate enum UserData {
        
        fileprivate static var accessToken: String = ""
        fileprivate static var refreshToken: String = ""
    }
}

// MARK: - Summary
extension APIEndpoints {
    
    /// 비디오 코드를 획득합니다.
    static func getVideoCode(with videoCodeRequestDTO: VideoCodeRequestDTO) -> Endpoint<ResponseDTOWrapper<VideoCodeResponseDTO>> {

        return Endpoint(
            path: "api/summaries/initiate",
            method: .post,
            headerParameters: [
                "Authorization" : "Bearer \(Self.UserData.accessToken)"
            ],
            bodyParametersEncodable: videoCodeRequestDTO
        )
    }
    
    /// 비디오 요약상태를 획득합니다.
    static func getVideoSummaryState(with videoCode: String) -> Endpoint<ResponseDTOWrapper<VideoSummaryStateResponseDTO>> {
        
        return Endpoint(
            path: "api/summaries/status/\(videoCode)",
            method: .get,
            headerParameters: [
                "Authorization" : "Bearer \(Self.UserData.accessToken)"
            ]
        )
    }
    
    /// 비디오 요약정보를 가져옵니다.
    static func getVideoDetail(with videoId: Int) -> Endpoint<ResponseDTOWrapper<VideoDetailResponseDTO>> {
        
        return Endpoint(
            path: "api/summaries/\(videoId)",
            method: .get,
            headerParameters: [
                "Authorization" : "Bearer \(Self.UserData.accessToken)"
            ]
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


// MARK: - VideoSubCategories
extension APIEndpoints {
    
    static func getVideoSubCategories(mainCategory main: String) -> Endpoint<ResponseDTOWrapper<VideoSubCategoryDTO>> {
        
        return Endpoint(
            path: "api/categories",
            method: .get,
            headerParameters: [
                "Authorization" : "Bearer \(Self.UserData.accessToken)"
            ],
            queryParameters: [
                "mainCategory" : main
            ]
        )
    }
}


// MARK: - Auth
extension APIEndpoints {
    
    static func getNewAuthToken(deviceIdentity: DeviceIdentityDTO) -> Endpoint<ResponseDTOWrapper<AuthTokenDTO>> {
        
        return Endpoint(
            path: "api/auth",
            method: .post,
            bodyParametersEncodable: deviceIdentity
        )
    }
    
    static func reissueAuthToken(prevToken: AuthTokenDTO) -> Endpoint<ResponseDTOWrapper<AuthTokenDTO>> {
        
        return Endpoint(
            path: "api/auth/reissue",
            method: .post,
            bodyParametersEncodable: prevToken
        )
    }
}
