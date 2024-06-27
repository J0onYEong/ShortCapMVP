import MainPageFeature
import Domain
import Data
import Swinject

struct MainPageAssembly: Assembly {
        
    func assemble(container: Container) {
        
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
        
        
        // MARK: - ViewModel
        container.register(MainViewModel.self) { resolver in
            MainViewModel(
                getVideoMainCategoryRepository: container.resolve(GetVideoMainCategoryRepository.self)!,
                videoMainCategoryViewModelFactory: container.resolve(VideoMainCategoryViewModelFactory.self)!,
                mainCategoryViewControllerFactory: container.resolve(MainCategoryViewControllerFactory.self)!
            )
        }
        container.register(VideoListViewModelInterface.self) { resolver in
            
            DefaultVideoListViewModel(
                fetchVideoIdentityUseCase: container.resolve(FetchVideoIdentityUseCase.self)!,
                videoCellViewModelFactory: container.resolve(VideoCellViewModelFactory.self)!
            )
        }
        
        // MARK: - ViewController
        container.register(MainViewController.self) { resolver in
            
            MainViewController(
                mainViewModel: resolver.resolve(MainViewModel.self)!,
                videoListViewModel: resolver.resolve(VideoListViewModelInterface.self)!
            )
        }
    }
}
