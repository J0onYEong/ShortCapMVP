//
//  SummaryContentRowCell.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/3/24.
//

import UIKit

class SummaryContentRowCell: UITableViewCell {
    
    var summayContentViewModel: SummaryContentViewModel!
    
    var cellType: SCRowCellType = .middleCell
    
    // View
    let thumbNailView: UIImageView = {
        
        let uiImageView = UIImageView()
        
        uiImageView.layer.backgroundColor = UIColor.gray.cgColor
        
        uiImageView.contentMode = .scaleAspectFill
        
        uiImageView.translatesAutoresizingMaskIntoConstraints = false
        
        return uiImageView
    }()
    
    let titleView: UILabel = {
       
        let labelView = UILabel()
        
        labelView.lineBreakMode = .byTruncatingTail
        
        labelView.translatesAutoresizingMaskIntoConstraints = false
        
        return labelView
    }()
    
    let stackView: UIStackView = {
        
        let view = UIStackView()
        
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .leading
        view.spacing = 10
        view.backgroundColor = .white
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAutoLayout() {
        
        self.backgroundColor = .gray
        
        self.addSubview(stackView)
        
        stackView.addArrangedSubview(thumbNailView)
        stackView.addArrangedSubview(titleView)
        
        NSLayoutConstraint.activate([
            
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1.0),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1.0),
            
            thumbNailView.widthAnchor.constraint(equalToConstant: SFTableViewConfig.imageWidth),
            thumbNailView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 5),
            thumbNailView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 5),
            thumbNailView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -5),
            
            titleView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 5),
        ])
    }
    
    func setUp(cellType: SCRowCellType) {
        
        setTitleText(text: summayContentViewModel.title)
        
        summayContentViewModel.fetchCompletion = { [weak self] in
            
            self?.setTitleText(text: self?.summayContentViewModel.title ?? "")
        }
        
        setCellBorder(type: cellType)
        
//        summayContentViewModel.checkIsFetched()
    }
    
    func setTitleText(text: String) {
        
        titleView.text = text
    }
    
    func setCellBorder(type: SCRowCellType) {
        
        var topConstant: CGFloat = 1.0
        var bottomConstant: CGFloat = 1.0
        
        if type == .topCell {
            
            bottomConstant = 0.5
            
        } else if type == .middleCell {
            
            topConstant = 0.5
            bottomConstant = 0.5
        } else {
            
            topConstant = 0.5
        }
        
        NSLayoutConstraint.activate([
            
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: topConstant),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -bottomConstant)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

