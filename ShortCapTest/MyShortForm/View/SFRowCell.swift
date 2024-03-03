//
//  SFRowCell.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/3/24.
//

import UIKit

class SFRowCell: UITableViewCell {
    
    var sFViewModel: SFViewModel! {
        
        didSet {
            
            whenModelSetted()
        }
    }
    
    // View
    let thumbNailView: UIImageView = {
        
        let uiImageView = UIImageView()
        
        uiImageView.layer.cornerRadius = 10
        uiImageView.layer.backgroundColor = UIColor.gray.cgColor
        
        uiImageView.contentMode = .scaleAspectFill
        
        uiImageView.translatesAutoresizingMaskIntoConstraints = false
        
        return uiImageView
    }()
    
    let titleView: UILabel = {
       
        let labelView = UILabel()
        
        labelView.translatesAutoresizingMaskIntoConstraints = false
        
        return labelView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAutoLayout() {
        
        self.layer.backgroundColor = UIColor.red.withAlphaComponent(0.3).cgColor
        
        self.addSubview(thumbNailView)
        
        self.addSubview(titleView)
        
        NSLayoutConstraint.activate([
            thumbNailView.widthAnchor.constraint(equalToConstant: SFTableViewConfig.imageWidth),
            thumbNailView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            thumbNailView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            thumbNailView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            
            titleView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            titleView.leadingAnchor.constraint(equalTo: thumbNailView.leadingAnchor, constant: 10)
        ])
    }
    
    func whenModelSetted() {
        
        titleView.text = sFViewModel.title
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.thumbNailView.clipsToBounds = true
        self.thumbNailView.layer.cornerRadius = 10
    }
}

