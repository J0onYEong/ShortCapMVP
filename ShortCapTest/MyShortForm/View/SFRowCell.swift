//
//  SFRowCell.swift
//  ShortCapTest
//
//  Created by 최준영 on 3/3/24.
//

import UIKit

class SFRowCell: UITableViewCell {
    
    var sFViewModel: SFViewModel!
    
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
        
        self.layer.backgroundColor = UIColor.red.withAlphaComponent(0.3).cgColor
        
        self.addSubview(stackView)
        
        stackView.addArrangedSubview(thumbNailView)
        stackView.addArrangedSubview(titleView)
        
        NSLayoutConstraint.activate([
            
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            thumbNailView.widthAnchor.constraint(equalToConstant: SFTableViewConfig.imageWidth),
            thumbNailView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 5),
            thumbNailView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 5),
            thumbNailView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -5),
            
            titleView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 5),
        ])
    }
    
    func setUp() {
        
        viewConfigure()
        
        sFViewModel.fetchCompletion = {
            
            self.viewConfigure()
        }
        
        sFViewModel.checkIsFetched()
    }
    
    func viewConfigure() {

        titleView.text = sFViewModel.title
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.thumbNailView.clipsToBounds = true
        self.thumbNailView.layer.cornerRadius = 10
    }
}

