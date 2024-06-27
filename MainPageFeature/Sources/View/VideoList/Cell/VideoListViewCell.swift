import UIKit
import RxSwift
import RxCocoa
import Core
import Domain
import Data
import DSKit

class VideoListViewCell: UICollectionViewCell {
    
    var viewModel: VideoCellViewModelInterface?
    
    // View
    let thumbNailView: UIImageView = {
        
        let uiImageView = UIImageView()
        
        uiImageView.layer.backgroundColor = UIColor.lightGray.cgColor
        
        uiImageView.layer.cornerRadius = 5
        
        uiImageView.contentMode = .scaleAspectFill
        
        uiImageView.clipsToBounds = true
        
        uiImageView.translatesAutoresizingMaskIntoConstraints = false
        
        return uiImageView
    }()
    
    let titleLabel: PretendardLabel = {
        
        let labelView = PretendardLabel(text: "", fontSize: 20, fontWeight: .bold, isAutoResizing: true)
        
        labelView.textColor = DSColor.mainBlue300.color
        labelView.lineBreakMode = .byTruncatingTail
        
        labelView.translatesAutoresizingMaskIntoConstraints = false
        
        return labelView
    }()
    
    let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAutoLayout() {
        
        [thumbNailView, titleLabel].forEach { contentView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            
            thumbNailView.widthAnchor.constraint(equalToConstant: VideoCollectionViewConfig.thumbNailWidth),
            thumbNailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            thumbNailView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            thumbNailView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            titleLabel.leadingAnchor.constraint(equalTo: thumbNailView.trailingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
        ])
    }
    
    /// Cell이 컬랙션 뷰에 추가될 시 호출
    func setUp(viewModel: VideoCellViewModelInterface) {
        
        self.viewModel = viewModel
        
        viewModel.detailSubject
            .asDriver(onErrorJustReturn: .mock)
            .drive(onNext: { [weak self] detail in
                
                self?.titleLabel.text = detail.title
            })
            .disposed(by: disposeBag)
        
        viewModel.thumbNailSubject
            .asDriver(onErrorJustReturn: UIImage())
            .drive(onNext: { [weak self] image in
                
                self?.thumbNailView.image = image
            })
            .disposed(by: disposeBag)
    }
}
