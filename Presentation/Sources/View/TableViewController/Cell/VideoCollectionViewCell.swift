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
    
    var activityIndicator: UIActivityIndicatorView = {
        
        let activityIndicator = UIActivityIndicatorView()
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .lightGray
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return activityIndicator
    }()
    
    let disposeBag: DisposeBag = .init()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAutoLayout() {
        
        [thumbNailView, titleLabel, activityIndicator].forEach { contentView.addSubview($0) }
        
        NSLayoutConstraint.activate([
            
            thumbNailView.widthAnchor.constraint(equalToConstant: VideoCollectionRowConfig.thumbNailWidth),
            thumbNailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            thumbNailView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            thumbNailView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            titleLabel.leadingAnchor.constraint(equalTo: thumbNailView.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    /// Cell이 컬랙션 뷰에 추가될 시 호출
    func setUp(viewModel: VideoCellViewModel) {
        
        self.viewModel = viewModel
        
        startShowingIndicator()
        
        viewModel.videoDetailSubject
            .asDriver(onErrorRecover: { error in
                
                // TODO: Detail을 가져오는 도중 에러발생, UI처리
                
                return Driver.just(.mock)
            })
            .drive(onNext: { detail in
                
                self.titleLabel.text = detail.title
                
                self.stopShowingIndicator()
            })
            .disposed(by: disposeBag)
        
        viewModel.thumbNailUrlSubject
            .asDriver(onErrorRecover: { error in
                
                // TODO: 기본 이미지 제공
                
                return Driver.just("")
            })
            .drive(onNext: { urlStr in
                
                self.thumbNailView.setImage(with: urlStr)
            })
            .disposed(by: disposeBag)
        
        viewModel.fetchDetail()
    }
    
    /// 셀이 재사용 대기를 하며 호출
    override func prepareForReuse() {
        
        titleLabel.text = ""
        
        stopShowingIndicator()
        
        viewModel = nil
    }
    
    func startShowingIndicator() { activityIndicator.startAnimating() }
    
    func stopShowingIndicator() { activityIndicator.stopAnimating() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 7.0, left: 0, bottom: 7, right: 0))
    }
}


