import Foundation
import Domain
import Core

public class DefaultConvertUrlRepository: ConvertUrlRepository {
    
    var dataTransferService: DataTransferService
    
    public init(dataTransferService: DataTransferService) {
        self.dataTransferService = dataTransferService
    }
    
    public func convert(urlString: String, completion: @escaping (Result<VideoCode, Error>) -> Void) {
        
        let endPoint = APIEndpoints.getVideoCode(with: VideoCodeRequestDTO(url: urlString, categoryId: nil, categoryIncluded: false))
        
        dataTransferService.request(with: endPoint) { result in
            
            switch result {
            case .success(let responseDTO):
                
                guard let innerDTO = responseDTO.data else { return completion(.success(VideoCode(code: "Error code"))) }
                
                completion(.success(innerDTO.toDomain()))
                
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    public func convert(urlString: String) async throws -> VideoCode {
        
        let endPoint = APIEndpoints.getVideoCode(with: VideoCodeRequestDTO(url: urlString, categoryId: nil, categoryIncluded: false))
        
        do {
            
            let dto: ResponseDTOWrapper<VideoCodeResponseDTO> = try await dataTransferService.request(with: endPoint)
            
            guard let response = dto.data else { throw ConvertUrlToVideoCodeUseCaseError.networkError }
            
            return response.toDomain()
            
        } catch {
            
            if let dataTransferError = error as? DataTransferError {
                
                let resolvedError = self.resolve(error: dataTransferError)
                
                throw resolvedError
            }
            
            throw error
        }
    }
    
    private func resolve(error: DataTransferError) -> ConvertUrlToVideoCodeUseCaseError {
        
        switch error {
        case .noResponse:
            return .networkError
        case .parsing( _ ):
            return .applicationError
        default:
            return .unknownError
        }
    }
}
