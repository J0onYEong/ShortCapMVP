import Foundation
import Swinject
import Domain
import Data
import Presentation
import Core

final class DIContainer {
    
    public static let container: Container = {
       
        let container = Container()
        
        // Storage
        container.register(VideoIdentityStorage.self) { _ in CoreDataVideoIdentityStorage(coreDataStorage: .shared) }
        container.register(VideoDetailStorage.self) { _ in CoreDataVideoDetailStorage(coreDataStorage: .shared) }
        container.register(VideoThumbNailSourceStorage.self) { _ in DefaultVideoThumbNailSourceStorage(storage: .shared) }
        
        // Service
        container.register(NetworkService.self, name: "default") { _ in DefaultNetworkService() }
        container.register(NetworkService.self, name: "googleAPi") { _ in
            
            DefaultNetworkService(config: ApiDataNetworkConfig.googleApi)
        }
        container.register(DataTransferService.self, name: "default") { resolver in
            
            DefaultDataTransferService(
                with: resolver.resolve(NetworkService.self, name: "default")!
            )
        }
        container.register(DataTransferService.self, name: "googleAPi") { resolver in
            
            DefaultDataTransferService(
                with: resolver.resolve(NetworkService.self, name: "googleAPi")!
            )
        }
        
        // Repo
        container.register(SaveVideoIdentityRepository.self) { resolver in
            
            DefaultSaveVideoIdentityRepository(
                videoIdentityStorage: resolver.resolve(VideoIdentityStorage.self)!
            )
        }
        container.register(ConvertUrlRepository.self) { resolver in
            DefaultConvertUrlRepository(
                dataTransferService: resolver.resolve(DataTransferService.self, name: "default")!
            )
        }
        container.register(FetchVideoIdentityRepository.self) { resolver in
            DefaultFetchVideoIdentityRepository(
                videoIdentityStorage: resolver.resolve(VideoIdentityStorage.self)!
            )
        }
        
        
        container.register(SummaryProcessRepository.self) { resolver in
            DefaultSummaryProcessRepository(
                dataTransferService: resolver.resolve(DataTransferService.self, name: "default")!
            )
        }
        container.register(VideoDetailLocalRepository.self) { resolver in
            DefaultVideoDetailRepository(
                storage: resolver.resolve(VideoDetailStorage.self)!
            )
        }
        container.register(LocalThumbNailSourceRepository.self) { resolver in
            
            DefaultLocalThumbNailSourceRepository(
                storage: resolver.resolve(VideoThumbNailSourceStorage.self)!
            )
        }
        
        
        // Youtube ThumbNail
        container.register(FetchThumbNailRepository.self, name: "youtube") { resolver in
            
            YoutubeThumbNailRepository(
                dataTransferService: resolver.resolve(DataTransferService.self, name: "googleAPi")!
            )
        }
        
        // UseCase
        container.register(UrlValidationUseCase.self) { _ in
            DefaultUrlValidationUseCase()
        }
        container.register(SaveVideoIndentityUserCase.self) { resolver in
            DefualtSaveVideoIndentityUseCase(
                saveVideoIdentityRepository: resolver.resolve(SaveVideoIdentityRepository.self)!
            )
        }
        container.register(ConvertUrlToVideoCodeUseCase.self) { resolver in
            DefaultConvertUrlToVideoCodeUseCase(
                convertUrlRepository: resolver.resolve(ConvertUrlRepository.self)!
            )
        }
        container.register(FetchVideoIdentityUseCase.self) { resolver in
            DefaultFetchVideoIdentityUseCase(
                fetchVideoIdentityRepository: resolver.resolve(FetchVideoIdentityRepository.self)!
            )
        }

        // detail
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
                youtubeRepository: resolver.resolve(FetchThumbNailRepository.self, name: "youtube")!,
                localRepository: resolver.resolve(LocalThumbNailSourceRepository.self)!
            )
        }
        
        
        // ViewModel
        container.register(VideoCollectionViewModel.self) { resolver in
            
            DefaultVideoCollectionViewModel(
                fetchVideoIdentityUseCase: resolver.resolve(FetchVideoIdentityUseCase.self)!,
                cellVMFactory: VideoCellViewModelFactory(
                    checkSummaryStateUseCase: resolver.resolve(CheckSummaryStateUseCase.self)!,
                    fetchVideoDetailUseCase: resolver.resolve(FetchVideoDetailUseCase.self)!,
                    saveVideoDetailUseCase: resolver.resolve(SaveVideoDetailUseCase.self)!,
                    videoThumbNailUseCase: resolver.resolve(VideoThumbNailUseCase.self)!
                )
            )
        }
        
        return container
    }()

    
    private init() { }

}
