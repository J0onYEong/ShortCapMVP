import Foundation
import Domain
import Core
import Data

enum ActionViewError: Error {
    
    case urlInvalidation
    case saveFailure
}

class ActionViewModel {
    
    let saveVideoCodeUseCase: SaveVideoCodeUseCase
    let convertUrlUseCase: ConvertUrlToVideoCodeUseCase
    let urlValidationUseCase: UrlValidationUseCase
    
    init(
        saveVideoCodeUseCase: SaveVideoCodeUseCase = DefaultSaveVideoCodeUseCase(
            saveVideoCodeRepository: DefaultSaveVideoCodeRepository(
                storage: CoreDataVideoCodeStorage()
            )
        ),
        convertUrlUseCase: ConvertUrlToVideoCodeUseCase = DefaultConvertUrlToVideoCodeUseCase(
            convertUrlRepository: DefaultConvertVideoCodeRepository(
                dataTransferService: DefaultDataTransferService(
                    with: DefaultNetworkService(
                        config: ApiDataNetworkConfig.default,
                        sessionManager: DefaultNetworkSessionManager()
                    )
                )
            )
        ),
        urlValidationUseCase: UrlValidationUseCase = DefaultUrlValidationUseCase()
    ) {
        self.saveVideoCodeUseCase = saveVideoCodeUseCase
        self.convertUrlUseCase = convertUrlUseCase
        self.urlValidationUseCase = urlValidationUseCase
    }

    func validateUrl(urlStr: String, completion: @escaping (Result<VideoCode, Error>) -> Void) {
        
        // 유효한 url인지 확인하기
        guard urlValidationUseCase.excute(url: urlStr) else {
            
            printIfDebug("‼️유요하지 않은 url형식: \(urlStr)")
            
            return completion(.failure(ActionViewError.urlInvalidation))
        }
        
        // url로 부터 비디오 코드 획득
        Task {
            
            do {
                
                let videoCode = try await convertUrlUseCase.execute(url: urlStr)
                
                printIfDebug("✅획득코드: \(videoCode.code)")
                
                // 획득한 코드를 저장
                saveVideoCodeUseCase.execute(videoCode: videoCode) { viedoCode in
                    
                    printIfDebug("✅저장된 비디오 코드: \(videoCode.code)")
                    
                    return completion(.success(videoCode))
                }
            } catch {
                
                printIfDebug("비디오 코드 획득 실패: \(urlStr)")
                
                completion(.failure(error))
            }
        }
    }
}
