import UIKit
import RxSwift
import RxCocoa
import Core
import Domain
import Data

public protocol SummaryContentViewModel {
    
    var rowDataRelay: BehaviorRelay<[VideoCode]> { get set }
    
    func bindWith<T: UITableViewCell>(
        tableView: UITableView,
        completion: @escaping (Int, VideoCode, T) -> Void)
    
    func fetchList()
    
    func fetchDetailForRow(videoCode: VideoCode, completion: @escaping (Result<VideoDetail, Error>) -> Void)
}

public class DefaultSummaryContentViewModel: SummaryContentViewModel {
    
    let fetchVideoCodeUseCase: FetchVideoCodesUseCase
    let videoDetailUseCase: VideoDetailUseCase
    
    public var rowDataRelay: BehaviorRelay<[VideoCode]> = BehaviorRelay(value: [])
    
    init(fetchVideoCodeUseCase: FetchVideoCodesUseCase, videoDetailUseCase: VideoDetailUseCase) {
        self.fetchVideoCodeUseCase = fetchVideoCodeUseCase
        self.videoDetailUseCase = videoDetailUseCase
    }
    
    
    public func fetchList() {
        
        fetchVideoCodeUseCase.execute { result in
            
            switch result {
            case .success(let videoCodes):
                
                self.rowDataRelay
                    .accept(videoCodes)
                
            case .failure(let failure):
                
                printIfDebug("‼️비디오 코드 불러오기 실패: \(failure.localizedDescription)")
            }
        }
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
    
    public func bindWith<T: UITableViewCell>(
        tableView: UITableView,
        completion: @escaping (Int, VideoCode, T) -> Void) {
        
        _ = rowDataRelay
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: String(describing: T.self),
                                         cellType: T.self), curriedArgument: completion)
    }
    
}
