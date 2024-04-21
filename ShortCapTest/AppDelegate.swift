import UIKit
import Swinject
import Data
import Domain
import Presentation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

//    let container: Container = {
//       
//        let container = Container()
//        
//        // Repository
//        container.register(SummaryRepositoryInterface.self) { _ in SummaryRepository() }
//        container.register(VideoCodeRepositoryInterface.self) { _ in VideoCodeRepository() }
//        container.register(StoreRepositoryInterface.self) { _ in StoreRepository() }
//        
//        // UserCase
//        container.register(SaveVideoCodeUseCaseInterface.self) { resolver in
//            SaveVideoCodeUseCase(
//                summaryRepo: resolver.resolve(SummaryRepositoryInterface.self)!,
//                videoRepo: resolver.resolve(VideoCodeRepositoryInterface.self)!
//            )
//        }
//        container.register(GetRowDataUseCaseInterface.self) { resolver in
//            GetRowDataUseCase(
//                summaryRepo: resolver.resolve(SummaryRepositoryInterface.self)!,
//                videoCodeRepo: resolver.resolve(VideoCodeRepositoryInterface.self)!,
//                storeRepo: resolver.resolve(StoreRepositoryInterface.self)!
//            )
//        }
//        container.register(SaveSummaryDataUseCaseInterface.self) { resolver in
//            SaveSummaryDataUseCase(
//                storeRepo: resolver.resolve(StoreRepositoryInterface.self)!
//            )
//        }
//        
//        // ViewModel
//        container.register(SummaryContentViewModel.self) { resolver in
//            
//            SummaryContentViewModel(
//                getRowDataUseCase: resolver.resolve(GetRowDataUseCaseInterface.self)!,
//                saveSummaryDataUseCase: resolver.resolve(SaveSummaryDataUseCaseInterface.self)!
//            )
//        }
//        
//        return container
//    }()


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

