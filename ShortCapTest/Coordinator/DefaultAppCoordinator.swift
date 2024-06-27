import UIKit
import OnBoardingPageFeature
import MainPageFeature
import Domain
import Core

class DefaultAppCoordinator: Coordinator {

    let injector: DependencyInjector
    let navigationController: UINavigationController
    
    var childCoordinators: [Coordinator] = []
    
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
    
    private func setNavigationBar() {
        
        navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    private func setOnBoardingCoordinator() {
        
        let coordinator = OnBoardingPageCoordinator(
            onBoardingViewController: injector.resolve(OnBoardingViewController.self),
            navigationController: navigationController
        )
        
        coordinator.delegate = self
        
        childCoordinators.append(coordinator)
    }
    
    private func setMainPageCoordinator() {
        
        let coordinator = MainPageCoordinator(
            mainViewController: injector.resolve(MainViewController.self),
            navigationController: navigationController
        )
        
        childCoordinators.append(coordinator)
    }
    
    public func showOnBoardingFlow() {
        
        getCoordinator(OnBoardingPageCoordinator.self)?.start()
    }
    
    public func showMainPageFlow() {
        
        getCoordinator(MainPageCoordinator.self)?.start()
    }
    
    public func getCoordinator<T>(_ type: T.Type) -> Coordinator? where T: Coordinator {
        
        childCoordinators.first(where: { ($0 as? T) != nil })
    }
}

extension DefaultAppCoordinator: OnBoardingPageCoordinatorDelegate {
    
    func tokenIssued(coordinator: OnBoardingPageCoordinator) {
        
        childCoordinators = childCoordinators.filter { $0 !== coordinator }
        
        showMainPageFlow()
    }
}
