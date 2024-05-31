import Domain
import Swinject

public struct DomainAssembly: Assembly {
    public func assemble(container: Container) {
        
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
                youtubeRepository: resolver.resolve(FetchThumbNailRepository.self, name: "youtube")!,
                localRepository: resolver.resolve(LocalThumbNailSourceRepository.self)!
            )
        }
    }
}
