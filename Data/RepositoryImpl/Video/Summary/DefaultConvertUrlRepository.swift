import Foundation
import Domain
import Core

public class DefaultConvertUrlRepository: ConvertUrlRepository {
    
    let networkService: NetworkService
    
    public init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    public func convert(urlString: String, categoryId: String?=nil, completion: @escaping (Result<String, Error>) -> Void) {
        
        let videoInfo = RawVideoInformationDTO(
            url: urlString,
            categoryId: categoryId,
            categoryIncluded: categoryId != nil
        )
        
        let requestConvertible = networkService.api.initiateSummary(videoInformation: videoInfo)
        
        networkService.network
            .request(requestConvertible: requestConvertible) { result in
                
                switch result {
                case .success(let responseDTO):
                    
                    guard let videoCode = responseDTO.data.videoCode else { return completion(.success("videocode isn't found")) }
                    
                    completion(.success(videoCode))
                    
                case .failure(let failure):
                    completion(.failure(failure))
                }
            }
    }
    
    public func convert(urlString: String, categoryId: String?=nil) async throws -> String {
        
        let videoInfo = RawVideoInformationDTO(
            url: urlString,
            categoryId: categoryId,
            categoryIncluded: categoryId != nil
        )
        
        let requestConvertible = await networkService.api.initiateSummary(videoInformation: videoInfo)
        
        do {
            
            let dto = try await networkService.network.request(requestConvertible: requestConvertible)
            
            guard let videoCode = dto.data.videoCode else { throw ConvertUrlToVideoCodeUseCaseError.networkError }
            
            return videoCode
        } catch {
        
            throw error
        }
    }
}
