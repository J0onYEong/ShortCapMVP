import UIKit
import Core

public class OnBoardingPageCoordinator: Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    
    public let viewController: OnBoardingViewController
    
    public let navigationController: UINavigationController
    
    public var delegate: OnBoardingPageCoordinatorDelegate?
    
    public init(
        onBoardingViewController: OnBoardingViewController,
        navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
        self.viewController = onBoardingViewController
    }
    
    public func start() {
        
        viewController.delegate = self
        
        self.navigationController.viewControllers = [viewController]
    }
}

extension OnBoardingPageCoordinator: OnBoardingViewControllerDeleage {
    
    public func tokenIssued() {
        
        self.delegate?.tokenIssued(coordinator: self)
    }
}

public protocol OnBoardingPageCoordinatorDelegate {
    
    func tokenIssued(coordinator: OnBoardingPageCoordinator)
}
