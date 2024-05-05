import Foundation
import Domain
import Core
import UIKit
import RxCocoa
import RxSwift

public protocol VideoCellViewModelFactory {
    
    func create(item: String) -> VideoCellViewModel
}

public class DefaultVideoCellViewModelFactory: VideoCellViewModelFactory {
    
    private let checkSummaryStateUseCase: CheckSummaryStateUseCase
    private let fetchVideoDetailUseCase: FetchVideoDetailUseCase
    private let saveVideoDetailUseCase: SaveVideoDetailUseCase

    private let videoThumbNailUseCase: VideoThumbNailUseCase
    
    public init(
        checkSummaryStateUseCase: CheckSummaryStateUseCase,
        fetchVideoDetailUseCase: FetchVideoDetailUseCase,
        saveVideoDetailUseCase: SaveVideoDetailUseCase,
        videoThumbNailUseCase: VideoThumbNailUseCase
    ) {
        self.checkSummaryStateUseCase = checkSummaryStateUseCase
        self.fetchVideoDetailUseCase = fetchVideoDetailUseCase
        self.saveVideoDetailUseCase = saveVideoDetailUseCase
        self.videoThumbNailUseCase = videoThumbNailUseCase
    }
    
    public func create(item: String) -> VideoCellViewModel {
        
        VideoCellViewModel(
            videoCode: item,
            checkSummaryStateUseCase: checkSummaryStateUseCase,
            fetchVideoDetailUseCase: fetchVideoDetailUseCase,
            saveVideoDetailUseCase: saveVideoDetailUseCase,
            videoThumbNailUseCase: videoThumbNailUseCase
        )
    }
}

public class VideoCellViewModel {
    
    private var videoCode: String
    public var videoDetail: VideoDetail?
    
    // Ovservables
    public let videoDetailSubject: PublishSubject<VideoDetail> = .init()
    public let thumbNailUrlSubject: PublishSubject<String> = .init()
    
    private let summaryStateSubject: PublishSubject<VideoSummaryState> = .init()
    
    public let disposebag: DisposeBag = .init()
    
    // UseCases
    private let checkSummaryStateUseCase: CheckSummaryStateUseCase
    private let fetchVideoDetailUseCase: FetchVideoDetailUseCase
    private let saveVideoDetailUseCase: SaveVideoDetailUseCase

    private let videoThumbNailUseCase: VideoThumbNailUseCase
    
    init(
        videoCode: String,
        checkSummaryStateUseCase: CheckSummaryStateUseCase,
        fetchVideoDetailUseCase: FetchVideoDetailUseCase,
        saveVideoDetailUseCase: SaveVideoDetailUseCase,
        videoThumbNailUseCase: VideoThumbNailUseCase
    ) {
        self.videoCode = videoCode
        self.checkSummaryStateUseCase = checkSummaryStateUseCase
        self.fetchVideoDetailUseCase = fetchVideoDetailUseCase
        self.saveVideoDetailUseCase = saveVideoDetailUseCase
        self.videoThumbNailUseCase = videoThumbNailUseCase
    }
    
    deinit {
        
        printIfDebug("cell ViewModel deinit")
    }
    
    private func makeSubscription() {
        
        summaryStateSubject
            .subscribe(
                onNext: { state in
                    
                    if state.status == .complete {
                        
                        self.fetchDetail(videoId: state.videoId)
                        self.summaryStateSubject.onCompleted()
                        
                        return
                    }
                    
                    DispatchQueue.global().asyncAfter(deadline: .now()+2) {
                        
                        self.checkSummaryState(videoCode: self.videoCode)
                    }
                }
            )
            .disposed(by: disposebag)
        
        /// 내부처리를 위한 부분으로 백그라운드에서 실행된다.
        videoDetailSubject
            .subscribe(
                onNext: { detail in
                    
                    // 내부적으로 값을 저장합니다.
                    self.videoDetail = detail
                    
                    // 디테일 정보를 바탕으로 썸네일을 가져옵니다.
                    self.fetchThumbNail(url: detail.url, platform: detail.platform)
                },
                onError: { error in
                        
                    // Network Error발생시 내부처리
                    
                })
            .disposed(by: disposebag)
    }

    /// #1. 로컬저장소로부터 디테일 정보를 요청하는 것을 가장먼저 수행
    public func fetchDetail() {
        
        self.makeSubscription()
        
        fetchVideoDetailUseCase.cache(videoCode: videoCode) { result in
            
            switch result {
            case .success(let videoDetail):
                
                self.videoDetailSubject
                    .onNext(videoDetail)
                
            case .failure(let error):
                
                if let ucError = error as? FetchVideoDetailUseCaseError {
                    
                    // 요약 상태 확인 시작
                    return self.checkSummaryState(videoCode: self.videoCode)
                }
                
                self.videoDetailSubject
                    .onError(error)
            }
        }
    }
    
    /// 네트워크로 부터 요청
    private func fetchDetail(videoId: Int) {
        
        fetchVideoDetailUseCase.fetch(videoId: videoId) { result in
            
            switch result {
            case .success(let videoDetail):
                
                self.saveVideoDetailUseCase.save(videoDetail: videoDetail) { isSuccess in
                    
                    printIfDebug(isSuccess ? "비디오 디테일 저장성공" : "비디오 디테일 저장실패")
                }
                
                self.videoDetailSubject
                    .onNext(videoDetail)
                
            case .failure(let error):
                
                self.videoDetailSubject
                    .onError(error)
            }
        }
    }
    
    /// 요약 상태 확인
    private func checkSummaryState(videoCode: String) {
        
        checkSummaryStateUseCase
            .check(videoCode: videoCode) { result in
                
                switch result {
                case .success(let state):
                    
                    self.summaryStateSubject
                        .onNext(state)
                    
                case .failure(let error):
                        
                    self.videoDetailSubject
                        .onError(error)
                }
            }
    }
}

extension VideoCellViewModel {
    
    private func fetchThumbNail(url: String, platform: VideoPlatform) {
        
        Task {
            
            if let url = videoThumbNailUseCase.fetchFromLocal(videoCode: videoCode) {
                
                self.thumbNailUrlSubject
                    .onNext(url)
                
                return
            }
            
            let videoInfo = VideoInformation(url: url, platform: platform)
            
            do {
                
                let thumbNailInfo = try await videoThumbNailUseCase.fetch(videoInfo: videoInfo, screenScale: UIScreen.main.scale)
                
                thumbNailUrlSubject
                    .onNext(thumbNailInfo.url)
                
                // 썸네일 주소 저장
                videoThumbNailUseCase.save(videoCode: videoCode, url: thumbNailInfo.url)
                
            } catch {
                
                self.thumbNailUrlSubject
                    .onError(error)
            }
        }
    }
}
