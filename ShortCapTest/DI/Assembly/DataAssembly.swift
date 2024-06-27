import Foundation
import Swinject
import Domain
import Data
import Core

public struct DataAssembly: Assembly {
    
    public func assemble(container: Container) {
        
        // MARK: - DataSource-Storage
        container.register(VideoIdentityStorage.self) { _ in CoreDataVideoIdentityStorage(coreDataStorage: .shared)
        }
        
        container.register(VideoDetailStorage.self) { _ in CoreDataVideoDetailStorage(coreDataStorage: .shared)
        }
        
        container.register(VideoThumbNailSourceStorage.self) { _ in DefaultVideoThumbNailSourceStorage(storage: .shared)
        }
        
        
        // MARK: - DataSource-Network
        container.register(NetworkConfigurable.self) { _ in DefaultNetworkConfiguration()
        }
        
        container.register(AuthCrendentialable.self) { _ in ShortcapAuthenticationCredential()
        }
        
        container.register(NetworkDataSource.self) { resolver in
            DefaultNetworkDataSource(
                configuration: resolver.resolve(NetworkConfigurable.self)!,
                credential: resolver.resolve(AuthCrendentialable.self)!
            )
        }
        
        // MARK: - Repository
        container.register(GetVideoMainCategoryRepository.self) { _ in
            
            DefaultGetMainVideoCategoryRepository()
        }
        
        container.register(GetVideoSubCategoryRepository.self) { resolver in
            
            DefaultGetVideoSubCategoryRepository(
                networkService: resolver.resolve(NetworkService.self)!
            )
        }
        
        container.register(FetchVideoIdentityRepository.self) { resolver in
            DefaultFetchVideoIdentityRepository(
                videoIdentityStorage: resolver.resolve(VideoIdentityStorage.self)!
            )
        }
        
        container.register(SummaryProcessRepository.self) { resolver in
            DefaultSummaryProcessRepository(
                networkService: resolver.resolve(NetworkService.self)!
            )
        }
        
        container.register(VideoDetailLocalRepository.self) { resolver in
            DefaultVideoDetailRepository(
                storage: resolver.resolve(VideoDetailStorage.self)!
            )
        }
        
        container.register(FetchThumbNailRepository.self, name: "youtube") { resolver in
            DefaultThumbNailRepository(
                networkService: resolver.resolve(NetworkService.self)!
            )
        }
        
        container.register(LocalThumbNailSourceRepository.self) { resolver in
            DefaultLocalThumbNailSourceRepository(
                storage: resolver.resolve(VideoThumbNailSourceStorage.self)!
            )
        }
        
        container.register(GetAuthTokenRepository.self) { resolver in
            DefaultGetAuthTokenRepository(
                networkService: resolver.resolve(NetworkService.self)!,
                credential: resolver.resolve(AuthCrendentialable.self)!
            )
        }
    }
}
