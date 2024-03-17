//
//  SummaryListViewController.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/3/24.
//

import UIKit

enum SFTableViewConfig {
    static var rowHeight: CGFloat {
        return 112
    }
    
    static var imageWidth: CGFloat {
        
        return 56
    }
}

class SummaryContentListViewController: UIViewController {
    
    // UIViews
    let sfTableView: UITableView = {
       
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    
    // ViewModel
    let summaryListViewModel: SummaryContentListViewModel
    
    
    // ViewController
    init(summaryListViewModel: SummaryContentListViewModel) {
        
        self.summaryListViewModel = summaryListViewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        summaryListViewModel.onModelIsModified = {
            
            self.sfTableView.reloadData()
        }
        
        summaryListViewModel.fetchLocalData()
        
        setUpAutoLayout()
        
        configureTableView()
    }
    
}

extension SummaryContentListViewController {
    
    func setUpAutoLayout() {
        
        self.view.addSubview(sfTableView)
        
        self.view.layer.backgroundColor = UIColor.white.cgColor
        
        NSLayoutConstraint.activate([
            sfTableView.topAnchor.constraint(equalTo: view.topAnchor),
            sfTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 21),
            sfTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -21),
            sfTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func configureTableView() {
        
        sfTableView.dataSource = self
        sfTableView.delegate = self
        sfTableView.rowHeight = SFTableViewConfig.rowHeight
        
        // Cell registration
        let sFRowCellId = String(describing: SFRowCell.self)
        sfTableView.register(SFRowCell.self, forCellReuseIdentifier: sFRowCellId)
    }
}


extension SummaryContentListViewController: UITableViewDelegate {
    
    
}

extension SummaryContentListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return summaryListViewModel.model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sFRowCellId = String(describing: SFRowCell.self)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: sFRowCellId, for: indexPath) as! SFRowCell
        
        cell.summayContentViewModel = self.summaryListViewModel.generateSFViewModel(index: indexPath.row)
        
        cell.setUp()
        
        return cell
    }
    
}
