import Foundation
import Domain
import Data

enum ActionViewError: Error {
    
    case invalidStringForUrl
    case retrievingFailedWithUrl
    
    case matchedDataNotFound
}

class ActionViewModel {
    
    let useCase = SaveVideoCodeUseCase(
        summaryRepo: SummaryRepository(),
        videoRepo: VideoCodeRepository()
    )

    func saveData(urlStr: String) async throws {
        
        // 유효한 url인지 확인하기
        guard useCase.checkUrlFormIsValid(urlString: urlStr) else { throw  ActionViewError.invalidStringForUrl }
        
        // url로 부터 비디오 코드 획득
        do {
            let code = try await useCase.getVideoCodeFrom(urlString: urlStr).videoCode
            
            // 도출한 코드를 저장
            useCase.saveVideoCode(videoCode: code)
            
        } catch {
            print("비디오코드 획득 오류 \(error.localizedDescription)")
            
            throw ActionViewError.retrievingFailedWithUrl
        }
    }
}
