import Foundation
import Domain
import Core
import UIKit

public protocol VideoCellViewModel {
    
    func fetchDetailForRow(videoCode: VideoCode, completion: @escaping (Result<VideoDetail, Error>) -> Void)
    func fetchThumbNail(videoInfo: VideoInformation, completion: @escaping (Result<VideoThumbNailInformation, Error>) -> Void)
}

public class DefaultVideoCellViewModel: VideoCellViewModel {
    
    let videoDetailUseCase: VideoDetailUseCase
    let videoThumbNailUseCase: VideoThumbNailUseCase
    
    public init(
        videoDetailUseCase: VideoDetailUseCase,
        videoThumbNailUseCase: VideoThumbNailUseCase
    ) {
        self.videoDetailUseCase = videoDetailUseCase
        self.videoThumbNailUseCase = videoThumbNailUseCase
    }
    
    public func fetchDetailForRow(videoCode: VideoCode, completion: @escaping (Result<VideoDetail, Error>) -> Void) {
        
        videoDetailUseCase.getDetailFromLocal(videoCode: videoCode) { result in
            
            switch result {
            case .success(let detail):
                
                printIfDebug("✅ \(videoCode.code) 캐싱 데이터 사용")
                
                completion(.success(detail))
            case .failure(let failure):
                
                if let error = failure as? FetchVideoDetailFromLocalError, error == .dataNotFound {
                    
                    printIfDebug("🥲 \(videoCode.code) 로컬에 데이터가 없음")
                    
                    // 네트워크 요청 시작
                    self.fetchDetailForRow(videoCode: videoCode, fetchingCount: 1, completion: completion)
                                        
                } else {
                    
                    completion(.failure(failure))
                }
            }
        }
    }
    
    private func fetchDetailForRow(videoCode: VideoCode, fetchingCount: Int, completion: @escaping (Result<VideoDetail, Error>) -> Void) {
        
        printIfDebug("👀 \(videoCode.code) \(fetchingCount)번째 요청시작")
        
        self.videoDetailUseCase.getDetail(videoCode: videoCode) { result in
            
            switch result {
            case .success(let success):
                
                // 비디오 디테일 저장
                self.videoDetailUseCase.saveDetail(videoCode: videoCode, videoDetail: success) { _ in }
                
                completion(.success(success))
                
            case .failure(let failure):
                
                if let error = failure as? FetchVideoDetailError, error == .videoIsProcessing {
                    
                    DispatchQueue.global().asyncAfter(deadline: .now()+2) {
                        
                        self.fetchDetailForRow(videoCode: videoCode, fetchingCount: fetchingCount+1, completion: completion)
                    }
                } else {
                    
                    completion(.failure(failure))
                }
            }
        }
    }
}

extension DefaultVideoCellViewModel {
    
    public func fetchThumbNail(videoInfo: VideoInformation, completion: @escaping (Result<VideoThumbNailInformation, Error>) -> Void) {
        
        let screenScale = UIScreen.main.scale
        
        Task {
            
            do {
                
                let thumbNailInfo = try await videoThumbNailUseCase.fetch(videoInfo: videoInfo, screenScale: screenScale)
                
                completion(.success(thumbNailInfo))
                
            } catch {
                
                completion(.failure(error))
            }
        }
    }
}
