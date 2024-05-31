import UIKit
import OnBoardingFeature
import MainFeature
import Domain

protocol AppCoordinator {
    
    var injector: DependencyInjector { get }
    var navigationController: UINavigationController { get }
    
    func start()
}

class DefaultAppCoordinator: AppCoordinator {
    
    let injector: DependencyInjector
    let navigationController: UINavigationController
    
    var controllers: [AppCoordinator] = []
    
    init(injector: DependencyInjector, navigationController: UINavigationController) {
        self.injector = injector
        self.navigationController = navigationController
    }
    
    func start() {
        
        setNavigationBar()
        setOnBoardingCoordinator()
        setMainPageCoordinator()
        showOnBoardingFlow()
    }
    
    func fetchToken() {
        
        _ = injector.resolve(GetAuthTokenRepository.self).getCurrentToken()
    }
    
    private func setNavigationBar() {
        
        navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    private func setOnBoardingCoordinator() {
        
        let coordinator = OnBoardingCoordinator(
            injector: injector,
            navigationController: navigationController
        )
        
        coordinator.deleage = self
        
        controllers.append(coordinator)
    }
    
    private func setMainPageCoordinator() {
        
        let coordinator = MainPageCoordinator(
            injector: injector,
            navigationController: navigationController
        )
        
        controllers.append(coordinator)
    }
    
    public func showOnBoardingFlow() {
        
        let coordinator = controllers.first(where: { $0 as? OnBoardingCoordinator != nil })!
        
        coordinator.start()
    }
    
    public func showMainPageFlow() {
        
        let coordinator = controllers.first(where: { $0 as? MainPageCoordinator != nil })!
        
        coordinator.start()
    }
}

extension DefaultAppCoordinator: CoordinatorFinishDelegate {
    
    func coordinatorFinished(coordinator: AppCoordinator) {
        
        if coordinator as? OnBoardingCoordinator != nil {
            
            controllers.removeAll(where: { $0 as? OnBoardingCoordinator != nil })
            
            DispatchQueue.main.async {
                self.showMainPageFlow()
            }
        }
    }
}

protocol CoordinatorFinishDelegate {
    
    func coordinatorFinished(coordinator: AppCoordinator)
}

// MARK: - OnBoardingCoordinator
class OnBoardingCoordinator: AppCoordinator {
    
    var injector: DependencyInjector
    var navigationController: UINavigationController
    
    var deleage: CoordinatorFinishDelegate?
    
    init(injector: DependencyInjector, navigationController: UINavigationController) {
        self.injector = injector
        self.navigationController = navigationController
    }
    
    func start() {
        
        let viewController = injector.resolve(OnBoardingViewController.self)
        
        navigationController.pushViewController(viewController, animated: false)
        
        Task {
            
            if let _ = await viewController.viewModel.getToken() {
                
                return self.deleage?.coordinatorFinished(coordinator: self)
            }
            
            // MARK: - 토큰 획득 실패
        }
    }
}

class MainPageCoordinator: AppCoordinator {
    
    var injector: DependencyInjector
    var navigationController: UINavigationController
    
    init(injector: DependencyInjector, navigationController: UINavigationController) {
        self.injector = injector
        self.navigationController = navigationController
    }
    
    func start() {
        
        let viewController = injector.resolve(MainViewController.self)
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
