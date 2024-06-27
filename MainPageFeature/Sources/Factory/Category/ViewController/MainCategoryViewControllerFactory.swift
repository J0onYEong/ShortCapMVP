import Foundation

public class MainCategoryViewControllerFactory {
    
    public typealias Product = MainCategoryViewController
    
    public init() { }
    
    func create(viewModel: VideoMainCategoryViewModel) -> Product {
        
        return MainCategoryViewController(viewModel: viewModel)
    }
}
