import UIKit
import Domain

class SummaryContentRowCell: UITableViewCell {
    
    var entity: SummaryResultEntity!
    var viewModel: SummaryContentViewModel!
    
    // View
    let thumbNailView: UIImageView = {
        
        let uiImageView = UIImageView()
        
        uiImageView.layer.backgroundColor = UIColor.gray.cgColor
        
        uiImageView.contentMode = .scaleAspectFill
        
        uiImageView.translatesAutoresizingMaskIntoConstraints = false
        
        return uiImageView
    }()
    
    let titleLabel: UILabel = {
       
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
        stackView.addArrangedSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 1.0),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -1.0),
            
            thumbNailView.widthAnchor.constraint(equalToConstant: SFTableViewConfig.imageWidth),
            thumbNailView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 5),
            thumbNailView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 5),
            thumbNailView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -5),
            
            titleLabel.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 5),
        ])
    }
    
    func setUp(
        entity: SummaryResultEntity,
        viewModel: SummaryContentViewModel
    ) {
        
        self.entity = entity
        self.viewModel = viewModel
        
        if entity.isFetched { return updateUI() }
        
        // UIUpdate
        titleLabel.text = "로딩중..."
        
        Task { [weak self] in
            
            let result = try await viewModel.getSummaryResultFor(code: entity.videoCode)
            
            self?.entity = entity
            
            await viewModel.updateStoreWith(entity: result)
            
            /// Cell UI업데이트
            await MainActor.run {
                
                self?.updateUI()
            }
        }
    }
    
    func updateUI() {
        
        titleLabel.text = self.entity.title
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
