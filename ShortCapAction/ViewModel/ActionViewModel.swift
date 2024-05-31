import Foundation
import Domain
import Core
import Data

enum ActionViewError: Error {
    
    case urlInvalidation
    case saveFailure
}

class ActionViewModel {
    
    let saveVideoIndentityUserCase: SaveVideoIndentityUserCase
    let convertUrlUseCase: ConvertUrlToVideoCodeUseCase
    let urlValidationUseCase: UrlValidationUseCase
    let authTokenRepository: GetAuthTokenRepository
    
    init(
        saveVideoIndentityUserCase: SaveVideoIndentityUserCase,
        convertUrlUseCase: ConvertUrlToVideoCodeUseCase,
        urlValidationUseCase: UrlValidationUseCase,
        authTokenRepository: GetAuthTokenRepository
    ) {
        self.saveVideoIndentityUserCase = saveVideoIndentityUserCase
        self.convertUrlUseCase = convertUrlUseCase
        self.urlValidationUseCase = urlValidationUseCase
        self.authTokenRepository = authTokenRepository
    }

    func validateAndSaveUrl(urlStr: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        // 유효한 url인지 확인하기
        guard urlValidationUseCase.excute(url: urlStr) else {
            
            printIfDebug("‼️유요하지 않은 url형식: \(urlStr)")
            
            return completion(.failure(ActionViewError.urlInvalidation))
        }
        
        // url로 부터 비디오 코드 획득
        Task {
            
            do {
                
                if let token = authTokenRepository.getCurrentToken() {
                    
                    _ = await authTokenRepository.reissueToken(current: token)
                    
                } else {
                    
                    _ = await authTokenRepository.getNewToken()
                }
                
                let code = try await convertUrlUseCase.execute(url: urlStr)
                
                printIfDebug("✅ 코드획득성공: \(code)")
                
                let identity = VideoIdentity(videoCode: code, originUrl: urlStr)
                
                // 획득한 코드를 저장
                saveVideoIndentityUserCase.execute(videoIdentity: identity) { isSuccess in
                    
                    printIfDebug("✅ 저장성공: \(code)")
                    
                    completion(.success(code))
                }
            } catch {
                
                printIfDebug("‼️비디오 코드 획득 실패: \(urlStr), \(error.localizedDescription)")
                
                completion(.failure(error))
            }
        }
    }
}
