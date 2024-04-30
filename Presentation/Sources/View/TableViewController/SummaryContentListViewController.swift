import UIKit
import Domain
import Data
import RxSwift
import RxCocoa

public class SummaryContentListViewController: UIViewController {
    
    // UIViews
    let tableView: UITableView = {
       
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // 스크롤 제거
        view.showsVerticalScrollIndicator = false
        
        // Cell 간격
        view.separatorStyle = .singleLine
        view.separatorColor = .clear
        
        return view
    }()
    
    // ViewModel
    public let viewModel: VideoTableViewModel
    
    // ViewController
    public init(viewModel: VideoTableViewModel) {
        
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        
        // 오토레이아웃 설정
        setUpAutoLayout()
        
        // 테이블뷰 설정
        configureTableView()
        
        // 옵저버블과 테이블셀 바인딩
        viewModel.bindWith(tableView: tableView)
    }
}

extension SummaryContentListViewController {
    
    func setUpAutoLayout() {
        
        self.view.addSubview(tableView)
        
        self.view.layer.backgroundColor = UIColor.white.cgColor
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func configureTableView() {
        
        tableView.delegate = self
        tableView.rowHeight = VideoTableRowConfig.rowHeight
        
        // Cell registration
        tableView.register(SummaryContentRowCell.self, forCellReuseIdentifier: String(describing: SummaryContentRowCell.self))
    }
}


extension SummaryContentListViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? SummaryContentRowCell {
            
            if let detail = cell.videoDetail {
                
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: SummaryContentListViewController.self))
                
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
