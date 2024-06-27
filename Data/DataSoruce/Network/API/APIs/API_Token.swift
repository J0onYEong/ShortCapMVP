import Foundation

// MARK: - 토큰
extension ShortcapAPI {
    
    /// 새로운 토큰을 발행한다.
    func issueToken(deviceIdentity: DeviceIdentityDTO) -> RequestBox<ResponseDTOWrapper<AuthTokenDTO>> {
        
        let endPoint = Endpoint(
            baseURL: configuration.baseURL,
            path: "api/auth",
            method: .post,
            headerParameters: configuration.baseHeader,
            bodyParametersEncodable: deviceIdentity
        )
        return RequestBox(
            endPoint: endPoint
        )
    }
}
