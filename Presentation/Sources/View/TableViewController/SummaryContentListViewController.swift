import UIKit
import Domain
import Data
import RxSwift
import RxCocoa

enum SFTableViewConfig {
    static var rowHeight: CGFloat {
        return 112
    }
    
    static var imageWidth: CGFloat {
        
        return 56
    }
}

public class SummaryContentListViewController: UIViewController {
    
    // UIViews
    let tableView: UITableView = {
       
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // 스크롤 제거
        view.showsVerticalScrollIndicator = false
        
        view.separatorStyle = .singleLine
        
        return view
    }()
    
    
    // ViewModel
    let viewModel: SummaryContentViewModel
    
    // ViewController
    init(viewModel: SummaryContentViewModel) {
        
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        
        setUpAutoLayout()
        
        configureTableView()
        
        viewModel.bindWith(tableView: tableView) { (index: Int, item: VideoCode, cell: SummaryContentRowCell) in
            
            cell.setUp(videoCode: item, viewModel: self.viewModel)
            cell.selectionStyle = .gray
        }
        
        viewModel.fetchList()
    }
}

extension SummaryContentListViewController {
    
    func setUpAutoLayout() {
        
        self.view.addSubview(tableView)
        
        self.view.layer.backgroundColor = UIColor.white.cgColor
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func configureTableView() {
        
        tableView.delegate = self
        tableView.rowHeight = SFTableViewConfig.rowHeight
        
        // Cell registration
        tableView.register(SummaryContentRowCell.self, forCellReuseIdentifier: String(describing: SummaryContentRowCell.self))
    }
}


extension SummaryContentListViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? SummaryContentRowCell {
            
            if let detail = cell.videoDetail {
                
                let storyboard = UIStoryboard(name: "Main", bundle: .main)
                
                let destinationVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                
                destinationVC.entity = detail
                
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let summaryRowCell = cell as? SummaryContentRowCell {
            
            summaryRowCell.getDetail()
        }
    }
}
