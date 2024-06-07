import UIKit
import Core

public class VideoListPageCoordinator: Coordinator {
    
    public var childCoordinators: [Coordinator] = []
    
    public let viewController: VideoListViewController
    
    public let navigationController: UINavigationController
    
    public init(
        videoListViewController: VideoListViewController,
        navigationController: UINavigationController
    ) {
        self.navigationController = navigationController
        self.viewController = videoListViewController
    }
    
    public func start() {
        
        navigationController.pushViewController(viewController, animated: true)
    }
}
