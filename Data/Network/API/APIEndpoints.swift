import Foundation
import Core

struct APIEndpoints {
    
    /// 비디오 코드를 획득합니다.
    static func getVideoCode(with videoCodeRequestDTO: VideoCodeRequestDTO) -> Endpoint<ResponseDTOWrapper<VideoCodeResponseDTO>> {

        return Endpoint(
            path: "api/summaries/initiate",
            method: .post,
            bodyParametersEncodable: videoCodeRequestDTO
        )
    }
}
