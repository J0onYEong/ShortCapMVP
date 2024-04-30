import UIKit
import Swinject
import Data
import Domain
import Core
import Presentation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let container: Container = {
       
        let container = Container()
        
        // Storage
        container.register(VideoCodeStorage.self) { _ in CoreDataVideoCodeStorage() }
        container.register(VideoDetailStorage.self) { _ in CoreDataVideoDetailStorage() }
        
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
        container.register(SaveVideoCodeRepository.self) { resolver in
            
            DefaultSaveVideoCodeRepository(
                storage: resolver.resolve(VideoCodeStorage.self)!
            )
        }
        container.register(ConvertUrlRepository.self) { resolver in
            DefaultConvertUrlRepository(
                dataTransferService: resolver.resolve(DataTransferService.self, name: "default")!
            )
        }
        container.register(FetchVideoCodesRepository.self) { resolver in
            DefaultFetchVideoCodesRepository(
                storage: resolver.resolve(VideoCodeStorage.self)!
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
        
        // Youtube ThumbNail
        container.register(VideoThumbNailRepository.self, name: "youtube") { resolver in
            
            YoutubeThumbNailRepository(
                dataTransferService: resolver.resolve(DataTransferService.self, name: "googleAPi")!
            )
        }
        
        // UseCase
        container.register(UrlValidationUseCase.self) { _ in
            DefaultUrlValidationUseCase()
        }
        container.register(SaveVideoCodeUseCase.self) { resolver in
            DefaultSaveVideoCodeUseCase(
                saveVideoCodeRepository: resolver.resolve(SaveVideoCodeRepository.self)!
            )
        }
        container.register(ConvertUrlToVideoCodeUseCase.self) { resolver in
            DefaultConvertUrlToVideoCodeUseCase(
                convertUrlRepository: resolver.resolve(ConvertUrlRepository.self)!
            )
        }
        container.register(FetchVideoCodesUseCase.self) { resolver in
            DefaultFetchVideoCodesUseCase(
                fetchVideoCodeRepository: resolver.resolve(FetchVideoCodesRepository.self)!
            )
        }
        container.register(VideoDetailUseCase.self) { resolver in
            DefaultVideoDetailUseCase(
                summaryProcessRepository: resolver.resolve(SummaryProcessRepository.self)!,
                videoDetailRepository: resolver.resolve(VideoDetailLocalRepository.self)!
            )
        }
        container.register(VideoThumbNailUseCase.self) { resolver in
            
            DefaultVideoThumbNailUseCase(
                youtubeThumbNailRepository: resolver.resolve(VideoThumbNailRepository.self, name: "youtube")!
            )
        }
        
        // ViewModel
        container.register(VideoCellViewModel.self) { resolver in
            DefaultVideoCellViewModel(
                videoDetailUseCase: resolver.resolve(VideoDetailUseCase.self)!,
                videoThumbNailUseCase: resolver.resolve(VideoThumbNailUseCase.self)!
            )
        }
        container.register(VideoTableViewModel.self) { resolver in
            
            DefaultVideoTableViewModel(
                fetchVideoCodeUseCase: resolver.resolve(FetchVideoCodesUseCase.self)!,
                videoCellViewModel: resolver.resolve(VideoCellViewModel.self)!
            )
        }
        
        return container
    }()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

