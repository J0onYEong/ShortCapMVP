import Foundation
import Swinject
import Domain
import Data
import Core
import MainFeature

enum Dependencies {
    
    enum NetworkService {
        
        static let `default` = "default"
        static let googleApi = "googleApi"
    }
    
    enum DataTransferService {
        
        static let `default` = "default"
        static let googleApi = "googleApi"
    }
    
    enum ThumbnailRepository {
        
        static let youtube = "youtube"
    }
}

class DIContainer {
    
    static let `default`: DIContainer = .init()
    
    private let container = Container()
    
    private init() {
        
        
        // MARK: - Storage
        container.register(VideoIdentityStorage.self) { _ in CoreDataVideoIdentityStorage(coreDataStorage: .shared)
        }
        
        container.register(VideoDetailStorage.self) { _ in CoreDataVideoDetailStorage(coreDataStorage: .shared)
        }
        
        container.register(VideoThumbNailSourceStorage.self) { _ in DefaultVideoThumbNailSourceStorage(storage: .shared)
        }
        
        
        // MARK: - Service
        container.register(NetworkService.self, name: Dependencies.NetworkService.default) { _ in DefaultNetworkService() }
        
        container.register(NetworkService.self, name: Dependencies.NetworkService.googleApi) { _ in
            
            DefaultNetworkService(config: ApiDataNetworkConfig.googleApi)
        }
        
        container.register(DataTransferService.self, name: Dependencies.DataTransferService.default) { resolver in
            
            DefaultDataTransferService(
                with: resolver.resolve(NetworkService.self, name: Dependencies.NetworkService.default)!
            )
        }
        
        container.register(DataTransferService.self, name: Dependencies.NetworkService.googleApi) { resolver in
            
            DefaultDataTransferService(
                with: resolver.resolve(NetworkService.self, name: Dependencies.NetworkService.googleApi)!
            )
        }
        
        
        
        // MARK: - Repository
        container.register(GetVideoMainCategoryRepository.self) { _ in
            
            DefaultGetMainVideoCategoryRepository()
        }
        
        container.register(GetVideoSubCategoryRepository.self) { resolver in
            
            DefaultGetVideoSubCategoryRepository(
                dataTransferService: resolver.resolve(DataTransferService.self, name: Dependencies.DataTransferService.default)!
            )
        }
        
        container.register(FetchVideoIdentityRepository.self) { resolver in
            DefaultFetchVideoIdentityRepository(
                videoIdentityStorage: resolver.resolve(VideoIdentityStorage.self)!
            )
        }
        
        container.register(SummaryProcessRepository.self) { resolver in
            DefaultSummaryProcessRepository(
                dataTransferService: resolver.resolve(DataTransferService.self, name: Dependencies.DataTransferService.default)!
            )
        }
        
        container.register(VideoDetailLocalRepository.self) { resolver in
            DefaultVideoDetailRepository(
                storage: resolver.resolve(VideoDetailStorage.self)!
            )
        }
        
        container.register(FetchThumbNailRepository.self, name: Dependencies.ThumbnailRepository.youtube) { resolver in
            
            YoutubeThumbNailRepository(
                dataTransferService: resolver.resolve(DataTransferService.self, name: Dependencies.DataTransferService.googleApi)!
            )
        }
        
        container.register(LocalThumbNailSourceRepository.self) { resolver in
            
            DefaultLocalThumbNailSourceRepository(
                storage: resolver.resolve(VideoThumbNailSourceStorage.self)!
            )
        }
        
        
        
        // MARK: - UseCase
        container.register(FetchVideoIdentityUseCase.self) { resolver in
            DefaultFetchVideoIdentityUseCase(
                fetchVideoIdentityRepository: resolver.resolve(FetchVideoIdentityRepository.self)!
            )
        }
        
        container.register(CheckSummaryStateUseCase.self) { resolver in
            DefaultCheckSummaryStateUseCase(
                summaryProcessRepository: resolver.resolve(SummaryProcessRepository.self)!
            )
        }
        
        container.register(FetchVideoDetailUseCase.self) { resolver in
            DefaultFetchVideoDetailUseCase(
                videoDetailRepository: resolver.resolve(VideoDetailLocalRepository.self)!,
                summaryProcessRepository: resolver.resolve(SummaryProcessRepository.self)!
            )
        }
        
        container.register(SaveVideoDetailUseCase.self) { resolver in
            DefaultSaveVideoDetailUseCase(
                videoDetailRepository: resolver.resolve(VideoDetailLocalRepository.self)!
            )
        }
        
        container.register(VideoThumbNailUseCase.self) { resolver in
            
            DefaultVideoThumbNailUseCase(
                youtubeRepository: resolver.resolve(FetchThumbNailRepository.self, name: Dependencies.ThumbnailRepository.youtube)!,
                localRepository: resolver.resolve(LocalThumbNailSourceRepository.self)!
            )
        }
        
        
        
        // MARK: - Factory
        container.register(SubCategoryCellViewModelFactory.self) { _ in
            
            SubCategoryCellViewModelFactory()
        }
        
        container.register(VideoMainCategoryViewModelFactory.self) { resolver in
            VideoMainCategoryViewModelFactory(
                getVideoSubCategoryRepository: resolver.resolve(GetVideoSubCategoryRepository.self)!,
                subCategoryCellViewModelFactory: resolver.resolve(SubCategoryCellViewModelFactory.self)!
            )
        }
        
        container.register(MainCategoryViewControllerFactory.self) { resolver in
            
            MainCategoryViewControllerFactory()
        }
        
        container.register(VideoCellViewModelFactory.self) { resolver in
            
            VideoCellViewModelFactory(
                checkSummaryStateUseCase: resolver.resolve(CheckSummaryStateUseCase.self)!,
                fetchVideoDetailUseCase: resolver.resolve(FetchVideoDetailUseCase.self)!,
                saveVideoDetailUseCase: resolver.resolve(SaveVideoDetailUseCase.self)!,
                videoThumbNailUseCase: resolver.resolve(VideoThumbNailUseCase.self)!)
        }
        
    }
    
    func createMainViewController() -> MainViewController {
        
        let mainViewModel = createMainViewModel()
        
        return MainViewController(
            mainViewModel: mainViewModel,
            videoListViewModel: createVideoListViewModel(mainViewModel: mainViewModel)
        )
    }
    
    private func createMainViewModel() -> MainViewModel {
        
        MainViewModel(
            getVideoMainCategoryRepository: container.resolve(GetVideoMainCategoryRepository.self)!,
            videoMainCategoryViewModelFactory: container.resolve(VideoMainCategoryViewModelFactory.self)!,
            mainCategoryViewControllerFactory: container.resolve(MainCategoryViewControllerFactory.self)!
        )
    }
    
    private func createVideoListViewModel(mainViewModel: MainViewModel) -> VideoListViewModelInterface {
        
        DefaultVideoListViewModel(
            fetchVideoIdentityUseCase: container.resolve(FetchVideoIdentityUseCase.self)!,
            videoCellViewModelFactory: container.resolve(VideoCellViewModelFactory.self)!,
            filterObservable: mainViewModel.getVideoFilterObservable()
        )
    }

}
