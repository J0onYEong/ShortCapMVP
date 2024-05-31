import UIKit
import Domain

public class OnBoardingViewController: UIViewController {
    
    public let viewModel: OnBoardingViewModel
    
    public init(viewModel: OnBoardingViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    let label: UILabel = {
       
        let view = UILabel()
        
        view.text = "로딩중"
        
        return view
    }()
    
    public override func viewDidLoad() {
        
        view.backgroundColor = .white
        
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}

public class OnBoardingViewModel {
    
    let getTokenRepository: GetAuthTokenRepository
    
    public init(getTokenRepository: GetAuthTokenRepository) {
        self.getTokenRepository = getTokenRepository
    }
    
    public func getToken() async -> AuthToken? {
        
        if let token = getTokenRepository.getCurrentToken() {
            
            return await getTokenRepository.reissueToken(current: token)
        } else {
            
            return await getTokenRepository.getNewToken()
        }
    }
}
