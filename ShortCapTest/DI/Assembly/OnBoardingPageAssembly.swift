import OnBoardingFeature
import Domain
import Data
import Swinject


struct OnBoardingPageAssembly: Assembly {
    
    func assemble(container: Container) {
        
        container.register(OnBoardingViewModel.self) { resolver in
            
            OnBoardingViewModel(
                getTokenRepository: resolver.resolve(GetAuthTokenRepository.self)!
            )
        }
        
        container.register(OnBoardingViewController.self) { resolver in
            
            OnBoardingViewController(
                viewModel: resolver.resolve(OnBoardingViewModel.self)!
            )
        }
    }
}
