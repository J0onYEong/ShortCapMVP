//
//  MySFViewController.swift
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

class MySFViewController: UIViewController {
    
    // UIViews
    let sfTableView: UITableView = {
       
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    
    // ViewModel
    let sFListViewModel: SFListViewModel
    
    
    // ViewController
    
    init(sFListViewModel: SFListViewModel) {
        
        self.sFListViewModel = sFListViewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        sFListViewModel.onModelIsModified = {
            
            self.sfTableView.reloadData()
        }
        sFListViewModel.fetchCellData()
        
        setUpAutoLayout()
        
        configureTableView()
    }
    
}

extension MySFViewController {
    
    func setUpAutoLayout() {
        
        self.view.addSubview(sfTableView)
        
        NSLayoutConstraint.activate([
            sfTableView.topAnchor.constraint(equalTo: view.topAnchor),
            sfTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sfTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
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


extension MySFViewController: UITableViewDelegate {
    
    
}

extension MySFViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sFListViewModel.model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sFRowCellId = String(describing: SFRowCell.self)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: sFRowCellId, for: indexPath) as! SFRowCell
        
        cell.sFViewModel = self.sFListViewModel.generateSFViewModel(index: indexPath.row)
        
        cell.setUp()
        
        return cell
    }
    
}
