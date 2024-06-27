import Foundation
import Alamofire

extension ShortcapAPI {
    
    /// 요약을 시작합니다.
    func initiateSummary(videoInformation: RawVideoInformationDTO) -> RequestBox<ResponseDTOWrapper<VideoCodeDTO>> {
        
        let endPoint = Endpoint(
            baseURL: configuration.baseURL,
            path: "api/summaries/initiate",
            method: .post,
            headerParameters: configuration.baseHeader,
            bodyParametersEncodable: videoInformation
        )
        return RequestBox(
            endPoint: endPoint,
            afInterceptor: tokenInterceptor.afTokenInterceptor
        )
    }
    
    /// 요약 상태를 가져옵니다.
    func fetchVideoSummaryState(videoCode: String) -> RequestBox<ResponseDTOWrapper<VideoSummaryStateResponseDTO>> {
        
        let endPoint = Endpoint(
            baseURL: configuration.baseURL,
            path: "api/summaries/status/\(videoCode)",
            method: .get,
            headerParameters: configuration.baseHeader
        )
        return RequestBox(
            endPoint: endPoint,
            afInterceptor: tokenInterceptor.afTokenInterceptor
        )
    }
}
