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
        container.register(NetworkService.self) { _ in DefaultNetworkService() }
        container.register(DataTransferService.self) { resolver in
            
            DefaultDataTransferService(
                with: resolver.resolve(NetworkService.self)!
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
                dataTransferService: resolver.resolve(DataTransferService.self)!
            )
        }
        container.register(FetchVideoCodesRepository.self) { resolver in
            DefaultFetchVideoCodesRepository(
                storage: resolver.resolve(VideoCodeStorage.self)!
            )
        }
        container.register(SummaryProcessRepository.self) { resolver in
            DefaultSummaryProcessRepository(
                dataTransferService: resolver.resolve(DataTransferService.self)!
            )
        }
        container.register(VideoDetailRepository.self) { resolver in
            DefaultVideoDetailRepository(
                storage: resolver.resolve(VideoDetailStorage.self)!
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
                videoDetailRepository: resolver.resolve(VideoDetailRepository.self)!
            )
        }
        
        // ViewModel
        container.register(SummaryContentViewModel.self) { resolver in
            
            DefaultSummaryContentViewModel(
                fetchVideoCodeUseCase: resolver.resolve(FetchVideoCodesUseCase.self)!,
                videoDetailUseCase: resolver.resolve(VideoDetailUseCase.self)!
            )
        }
        
        return container
    }()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

