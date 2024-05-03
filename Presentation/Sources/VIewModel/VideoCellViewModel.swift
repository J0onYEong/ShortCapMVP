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
    private var videoId: Int?
    
    public var onNetworkError: (() -> Void)?
    
    // Ovservables
    public let videoDetailRelay: PublishRelay<VideoDetail> = .init()
    public let thumbNailUrlRelay: PublishRelay<String> = .init()
    
    public var videoDetail: VideoDetail?
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
        
        stateSub()
    }
    
    deinit {
        
        printIfDebug("cell ViewModel deinit")
    }
    
    private func stateSub() {
        
        summaryStateSubject
            .subscribe(
                onNext: { state in
                    
                    if state.status == .complete {
                        
                        self.videoId = state.videoId
                        self.summaryStateSubject.onCompleted()
                        
                        return
                    }
                    
                    DispatchQueue.global().asyncAfter(deadline: .now()+2) {
                        
                        self.checkSummaryState(videoCode: self.videoCode)
                    }
                },
                onCompleted: {
                    
                    // 요약완료, 디데일정보 가져오기 시작
                    self.fetchDetail(videoId: self.videoId!)
                }
            )
            .disposed(by: disposebag)
        
        videoDetailRelay
            .subscribe(
                onNext: { detail in
                    
                    self.videoDetail = detail
                    
                    self.fetchThumbNail(url: detail.url, platform: detail.platform)
                })
            .disposed(by: disposebag)
    }

    /// #1. 로컬저장소 요청
    public func fetchDetail() {
        
        fetchVideoDetailUseCase.cache(videoCode: videoCode) { result in
            
            switch result {
            case .success(let videoDetail):
                
                if let videoDetail {
                    
                    self.videoDetailRelay
                        .accept(videoDetail)
                    
                    return
                }
                
                // 요약 상태 확인 시작
                self.checkSummaryState(videoCode: self.videoCode)
                
            case .failure(_):
                
                self.onNetworkError?()
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
                
                self.videoDetailRelay
                    .accept(videoDetail)
                
            case .failure(_):
                
                self.onNetworkError?()
            }
        }
    }
    
    private func checkSummaryState(videoCode: String) {
        
        checkSummaryStateUseCase
            .check(videoCode: videoCode) { result in
                
                switch result {
                case .success(let state):
                    
                    self.summaryStateSubject
                        .onNext(state)
                    
                case .failure(_):
                        
                    self.onNetworkError?()
                }
            }
    }
}

extension VideoCellViewModel {
    
    private func fetchThumbNail(url: String, platform: VideoPlatform) {
        
        Task {
            
            if let url = videoThumbNailUseCase.fetchFromLocal(videoCode: videoCode) {
                
                thumbNailUrlRelay
                    .accept(url)
                
                return
            }
            
            let videoInfo = VideoInformation(url: url, platform: platform)
            
            do {
                
                let thumbNailInfo = try await videoThumbNailUseCase.fetch(videoInfo: videoInfo, screenScale: UIScreen.main.scale)
                
                thumbNailUrlRelay
                    .accept(thumbNailInfo.url)
                
                // 썸네일 주소 저장
                videoThumbNailUseCase.save(videoCode: videoCode, url: thumbNailInfo.url)
                
            } catch {
                
                printIfDebug("썸네일을 가져오는 도중 문제발생 url: \(url)")
            }
        }
    }
}
