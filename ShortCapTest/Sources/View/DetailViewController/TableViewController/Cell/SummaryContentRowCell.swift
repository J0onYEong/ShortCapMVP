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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAutoLayout() {
        
        self.backgroundColor = .systemBlue.withAlphaComponent(0.5)
        
        [thumbNailView, titleLabel].forEach { self.addSubview($0) }
        
        NSLayoutConstraint.activate([

            thumbNailView.widthAnchor.constraint(equalToConstant: SFTableViewConfig.imageWidth),
            thumbNailView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            thumbNailView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            thumbNailView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            
            titleLabel.leadingAnchor.constraint(equalTo: thumbNailView.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
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
            
            do {
                
                let result = try await viewModel.getSummaryResultFor(code: self?.entity.videoCode ?? "")
                
                self?.entity = result
                
                await viewModel.updateStoreWith(entity: result)
                
                /// Cell UI업데이트
                await MainActor.run {
                    
                    self?.updateUI()
                }
                
            } catch {
             
                print(error)
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
