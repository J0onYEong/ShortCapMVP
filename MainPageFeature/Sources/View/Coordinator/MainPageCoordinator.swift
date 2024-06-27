import UIKit
import Core

public class MainPageCoordinator: Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    
    public let navigationController: UINavigationController
    
    public let viewController: MainViewController
    
    public init(
        mainViewController: MainViewController,
        navigationController: UINavigationController
    ) {
        self.viewController = mainViewController
        self.navigationController = navigationController
    }
    
    public func start() {
        
        viewController.videoListViewModel.fetchVideoIdentities()
        
        self.navigationController.viewControllers = [viewController]
    }
}
