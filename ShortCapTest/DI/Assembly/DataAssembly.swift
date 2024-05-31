import Foundation
import Swinject
import Domain
import Data
import Core

public struct DataAssembly: Assembly {
    
    public func assemble(container: Container) {
        
        // MARK: - Storage
        container.register(VideoIdentityStorage.self) { _ in CoreDataVideoIdentityStorage(coreDataStorage: .shared)
        }
        
        container.register(VideoDetailStorage.self) { _ in CoreDataVideoDetailStorage(coreDataStorage: .shared)
        }
        
        container.register(VideoThumbNailSourceStorage.self) { _ in DefaultVideoThumbNailSourceStorage(storage: .shared)
        }
        
        
        // MARK: - Service
        container.register(NetworkService.self, name: "default") { _ in DefaultNetworkService() }
        
        container.register(NetworkService.self, name: "googleApi") { _ in
            
            DefaultNetworkService(config: ApiDataNetworkConfig.googleApi)
        }
        
        container.register(DataTransferService.self, name: "default") { resolver in
            
            DefaultDataTransferService(
                with: resolver.resolve(NetworkService.self, name: "default")!
            )
        }
        
        container.register(DataTransferService.self, name: "googleApi") { resolver in
            
            DefaultDataTransferService(
                with: resolver.resolve(NetworkService.self, name: "googleApi")!
            )
        }
        
        // MARK: - Repository
        container.register(GetVideoMainCategoryRepository.self) { _ in
            
            DefaultGetMainVideoCategoryRepository()
        }
        
        container.register(GetVideoSubCategoryRepository.self) { resolver in
            
            DefaultGetVideoSubCategoryRepository(
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
        
        container.register(FetchThumbNailRepository.self, name: "youtube") { resolver in
            
            YoutubeThumbNailRepository(
                dataTransferService: resolver.resolve(DataTransferService.self, name: "googleApi")!
            )
        }
        
        container.register(LocalThumbNailSourceRepository.self) { resolver in
            DefaultLocalThumbNailSourceRepository(
                storage: resolver.resolve(VideoThumbNailSourceStorage.self)!
            )
        }
        
        container.register(GetAuthTokenRepository.self) { resolver in
            DefaultGetAuthTokenRepository(
                dataTransferService: resolver.resolve(DataTransferService.self, name: "default")!
            )
        }
        
        
    }
}
