import Foundation
import Domain

public class VideoCellViewModelFactory {
    
    private let checkStateUC: CheckSummaryStateUseCase
    private let fetchDetailUC: FetchVideoDetailUseCase
    private let saveDetailUC: SaveVideoDetailUseCase
    private let thumbNailUC: VideoThumbNailUseCase
    
    public init(
        checkSummaryStateUseCase checkStateUC: CheckSummaryStateUseCase,
        fetchVideoDetailUseCase fetchDetailUC: FetchVideoDetailUseCase,
        saveVideoDetailUseCase saveDetailUC: SaveVideoDetailUseCase,
        videoThumbNailUseCase thumbNailUC: VideoThumbNailUseCase
    ) {
        self.checkStateUC = checkStateUC
        self.fetchDetailUC = fetchDetailUC
        self.saveDetailUC = saveDetailUC
        self.thumbNailUC = thumbNailUC
    }
    
    func create(videoIdentity: VideoIdentity) -> VideoCellViewModel {
        
        DefaultVideoCellViewModel(
            videoIdentity: videoIdentity,
            checkSummaryStateUseCase: checkStateUC,
            fetchVideoDetailUseCase: fetchDetailUC,
            saveVideoDetailUseCase: saveDetailUC,
            videoThumbNailUseCase: thumbNailUC
        )
    }
}
