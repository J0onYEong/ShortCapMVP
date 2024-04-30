import UIKit
import Domain
import Kingfisher

class SummaryContentRowCell: UITableViewCell {
    
    var viewModel: VideoCellViewModel!
    
    private var videoCode: VideoCode!
    
    var videoDetail: VideoDetail?
    
    private var fetchingTask: Task<Void, Never>?
    
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAutoLayout() {
        
        [thumbNailView, titleLabel, activityIndicator].forEach { self.addSubview($0) }
        
        NSLayoutConstraint.activate([
            
            thumbNailView.widthAnchor.constraint(equalToConstant: VideoTableRowConfig.thumbNailWidth),
            thumbNailView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            thumbNailView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            thumbNailView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            
            titleLabel.leadingAnchor.constraint(equalTo: thumbNailView.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    func setUp(videoCode: VideoCode, viewModel: VideoCellViewModel) {
        
        self.viewModel = viewModel
        self.videoCode = videoCode
    }
    
    override func prepareForReuse() {
        
        fetchingTask?.cancel()
        videoDetail = nil
        videoCode = nil
        titleLabel.text = ""
        
        stopShowingIndicator()
    }
    
    func getDetail() {
        
        if videoDetail == nil {
            
            // 인디케이터 시작
            startShowingIndicator()
            
            fetchingTask = Task {
                
                self.viewModel.fetchDetailForRow(videoCode: videoCode) { result in
                    
                    switch result {
                    case .success(let videoDetail):
                        
                        DispatchQueue.main.async {
                            
                            self.videoDetail = videoDetail
                            self.updateUI()
                            
                            // 인디케이터 종료
                            self.stopShowingIndicator()
                            
                            // 썸네일 업데이트
                            self.updateThumbNail(videoDetail: videoDetail)
                        }
                        
                    case .failure(let failure):
                        
                        print("Cell, 디테일 데이터 가져오가 실패: \(failure.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func updateUI() {
        
        titleLabel.text = self.videoDetail?.title
    }
    
    func startShowingIndicator() {
        
        activityIndicator.startAnimating()
    }
    
    func stopShowingIndicator() {
        
        activityIndicator.stopAnimating()
    }
    
    func updateThumbNail(videoDetail: VideoDetail) {
        
        if videoDetail.platform != .youtube { return }
        
        let videoInfo = VideoInformation(url: videoDetail.url, platform: videoDetail.platform)
        
        viewModel.fetchThumbNail(videoInfo: videoInfo) { result in
            
            switch result {
            case .success(let thumbNailInfo):
                
                let urlString = thumbNailInfo.url
                
                print("✅ 비디오 썸네일 가져오기 성공: \(urlString)")
                
                OperationQueue.main.addOperation {
                    
                    self.thumbNailView.setImage(with: urlString)
                }
                
            case .failure(let failure):
                
                print("썸네일 가져오기 실패, \(failure)")
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 7.0, left: 0, bottom: 7, right: 0))
    }
}

extension UIImageView {
    
    func setImage(with urlString: String) {
        
        ImageCache.default.retrieveImage(forKey: urlString, options: nil) { result in
            
            switch result {
            case .success(let value):
                
                if let image = value.image {
                    
                    //캐시가 존재하는 경우
                    self.image = image
                    
                } else {
                    
                    //캐시가 존재하지 않는 경우
                    guard let url = URL(string: urlString) else { return }
                    
                    print("kingFisehr: \(urlString)")
                    
                    let resource = ImageResource(downloadURL: url, cacheKey: urlString)
                    
                    let processor = DownsamplingImageProcessor(size: self.bounds.size)
                    
                    self.kf.setImage(
                        with: resource,
                        options: [
                            .processor(processor),
                            .scaleFactor(UIScreen.main.scale),
                            .transition(.fade(0.5)),
                            .cacheOriginalImage,
                        ]
                    )
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
