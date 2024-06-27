import UIKit
import RxCocoa
import RxSwift
import Kingfisher
import Domain

enum VideoCollectionViewConfig {
    
    // TableInset
    static let horizontalInset: CGFloat = 20
    
    // RowHeight
    static var rowHeight: CGFloat { thumbNailHeight }
    
    // ThumbNail
    static let thumbNailHeight: CGFloat = 160
    static let thumbNailWidth: CGFloat = 120
    static var thumbNailSize: CGSize { CGSize(width: thumbNailWidth, height: thumbNailHeight) }
}

public protocol VideoCellViewModelInterface {
    
    var videoIdentity: VideoIdentity { get }
    var detail: VideoDetail? { get }
    
    var detailSubject: ReplaySubject<VideoDetail> { get }
    var thumbNailSubject: ReplaySubject<UIImage> { get }
    
    func fetchDetailAndThumbNail()
}

public final class DefaultVideoCellViewModel: VideoCellViewModelInterface {
    
    public let videoIdentity: VideoIdentity
    public var detail: VideoDetail?
    
    // UseCases
    private let checkStateUC: CheckSummaryStateUseCase
    private let fetchDetailUC: FetchVideoDetailUseCase
    private let saveDetailUC: SaveVideoDetailUseCase
    private let thumbNailUC: VideoThumbNailUseCase
    
    init(
        videoIdentity: VideoIdentity,
        checkSummaryStateUseCase checkStateUC: CheckSummaryStateUseCase,
        fetchVideoDetailUseCase fetchDetailUC: FetchVideoDetailUseCase,
        saveVideoDetailUseCase saveDetailUC: SaveVideoDetailUseCase,
        videoThumbNailUseCase thumbNailUC: VideoThumbNailUseCase
    ) {
        self.videoIdentity = videoIdentity
        self.checkStateUC = checkStateUC
        self.fetchDetailUC = fetchDetailUC
        self.saveDetailUC = saveDetailUC
        self.thumbNailUC = thumbNailUC
    }
    
    public let detailSubject: ReplaySubject<VideoDetail> = .create(bufferSize: 1)
    
    public let thumbNailSubject: ReplaySubject<UIImage> = .create(bufferSize: 1)
    
    private let stateSubject: PublishSubject<VideoSummaryState> = .init()
    
    private let disposeBag: DisposeBag = .init()
    
    private func makeSubscription() {
        
        stateSubject
            .observe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .subscribe(
                onNext: { state in
                    
                    if state.status == .complete {
                        
                        self.fetchDetail(videoId: state.videoId)
                        self.stateSubject.onCompleted()
                        
                        return
                    }
                    
                    DispatchQueue.global().asyncAfter(deadline: .now()+2) {
                        
                        let code = self.videoIdentity.videoCode
                        
                        self.checkSummaryState(videoCode: code)
                    }
                }
            )
            .disposed(by: disposeBag)
        
        // 내부처리를 위한 부분으로 백그라운드에서 실행된다.
        detailSubject
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(
                onNext: { detail in
                    
                    // detail 설정완료
                },
                onError: { error in
                        
                    // Network Error발생시 내부처리
                    
                })
            .disposed(by: disposeBag)
    }
    
    
    /// #1. Video Detail과 ThumbNail을 Fetch합니다.
    public func fetchDetailAndThumbNail() {
        
        self.makeSubscription()
        
        let code = videoIdentity.videoCode
        
        fetchThumbNail()
        
        fetchDetailUC.cache(videoCode: code) { result in
            
            switch result {
            case .success(let videoDetail):
                
                // 로컬에 저장된 정보를 사용함
                self.detail = videoDetail
                
                self.detailSubject
                    .onNext(videoDetail)
                
            case .failure(let error):
                
                // 로컬에 저장된 정보가 없는 경우
                
                if let _ = error as? FetchVideoDetailUseCaseError {
                    
                    // 요약 상태 확인 시작
                    return self.checkSummaryState(videoCode: code)
                }
                
                self.detailSubject
                    .onError(error)
            }
        }
    }
    
    /// 비디오 디테일을 네트워크로 부터 요청
    private func fetchDetail(videoId: Int) {
        
        fetchDetailUC.fetch(videoId: videoId) { result in
            
            switch result {
            case .success(let videoDetail):
                
                self.saveDetailUC.save(videoDetail: videoDetail)
                
                self.detail = videoDetail
                
                self.detailSubject
                    .onNext(videoDetail)
                
            case .failure(let error):
                
                self.detailSubject
                    .onError(error)
            }
        }
    }
    
    /// 비디오 요약 상태 확인
    private func checkSummaryState(videoCode: String) {
        
        checkStateUC
            .check(videoCode: videoCode) { result in
                
                switch result {
                case .success(let state):
                    
                    self.stateSubject
                        .onNext(state)
                    
                case .failure(let error):
                        
                    self.detailSubject
                        .onError(error)
                }
            }
    }
    
    /// 썸네일을 로드합니다.
    private func fetchThumbNail() {
        
        Task {
            
            let code = videoIdentity.videoCode
            
            // 로컬저장소에 저장된 정보를 가져옵니다.
            if let savedUrl = thumbNailUC.fetchFromLocal(videoCode: code) {
                
                return retrieveImage(
                    urlStr: savedUrl,
                    size: VideoCollectionViewConfig.thumbNailSize) { result in
                        
                        switch result {
                        case .success(let image):
                            
                            self.thumbNailSubject
                                .onNext(image)
                        case .failure(_):
                            
                            self.thumbNailSubject
                                .onNext(UIImage())
                        }
                    }
            }
            
            do {
                
                let thumbNailInfo = try await thumbNailUC.fetch(
                    videoIdentity: videoIdentity,
                    screenScale: UIScreen.main.scale
                )
                
                retrieveImage(
                    urlStr: thumbNailInfo.url,
                    size: VideoCollectionViewConfig.thumbNailSize) { result in
                        
                        switch result {
                        case .success(let image):
                            
                            self.thumbNailSubject
                                .onNext(image)
                        case .failure(_):
                            
                            self.thumbNailSubject
                                .onNext(UIImage())
                        }
                    }

                // 썸네일 정보 저장
                thumbNailUC.save(videoCode: code, url: thumbNailInfo.url)
                
            } catch {
                
                self.thumbNailSubject
                    .onNext(UIImage())
            }
        }
    }
    
    /// 이미지 url정보와 Kingfisher를 사용하여 UIImage를 획득합니다.
    private func retrieveImage(urlStr: String, size: CGSize, completion: @escaping ((Result<UIImage, Error>) -> Void)) {
        
        let url = URL(string: urlStr)!
//        let processor = ResizingImageProcessor(
//            referenceSize: CGSize(width: 100, height: 100),
//            mode: .aspectFill
//        )

        KingfisherManager.shared.retrieveImage(
            with: url,
            options: [
                .cacheOriginalImage
            ]) { result in
            switch result {
            case .success(let value):
                let resizedImage = value.image
                completion(.success(resizedImage))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension DefaultVideoCellViewModel {
    
    public static func == (lhs: DefaultVideoCellViewModel, rhs: DefaultVideoCellViewModel) -> Bool {
        
        lhs.videoIdentity == rhs.videoIdentity
    }
    
    public func hash(into hasher: inout Hasher) {
        
        hasher.combine(videoIdentity)
    }
}
