import UIKit
import Domain
import RxSwift
import RxCocoa
import Core

class VideoCollectionViewCell: UICollectionViewCell {
    
    var viewModel: VideoCellViewModel!
    
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
    
    let titleLabel: UILabel = {
        
        let labelView = UILabel()
        
        labelView.lineBreakMode = .byTruncatingTail
        
        labelView.translatesAutoresizingMaskIntoConstraints = false
        
        return labelView
    }()
    
//    var activityIndicator: UIActivityIndicatorView = {
//        
//        let activityIndicator = UIActivityIndicatorView()
//        
//        activityIndicator.hidesWhenStopped = true
//        activityIndicator.color = .lightGray
//        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
//        
//        return activityIndicator
//    }()
    
    let disposeBag: DisposeBag = .init()
    
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
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            
//            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    /// Cell이 컬랙션 뷰에 추가될 시 호출
    func setUp(viewModel: VideoCellViewModel) {
        
        self.viewModel = viewModel
        
        viewModel.detailSubject
            .asDriver(onErrorJustReturn: .mock)
            .drive(onNext: { detail in
                
                self.titleLabel.text = detail.title
            })
            .disposed(by: disposeBag)
        
        viewModel.thumbNailSubject
            .asDriver(onErrorJustReturn: UIImage())
            .drive(self.thumbNailView.rx.image)
            .disposed(by: disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 7.0, left: 0, bottom: 7, right: 0))
    }
    
    /// 셀이 재사용 대기를 하며 호출
    override func prepareForReuse() {

    }
}
