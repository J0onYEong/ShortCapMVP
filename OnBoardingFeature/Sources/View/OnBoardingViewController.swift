import UIKit
import Domain

protocol OnBoardingViewControllerDeleage {
    
    func tokenIssued()
}

public class OnBoardingViewController: UIViewController {
    
    public let viewModel: OnBoardingViewModel
    
    var delegate: OnBoardingViewControllerDeleage?
    
    public init(viewModel: OnBoardingViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        Task { [weak self] in
            
            if let _ = await self?.viewModel.getToken() {
                
                await MainActor.run { [weak self] in
                    
                    self?.delegate?.tokenIssued()
                }
            }
        }
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
