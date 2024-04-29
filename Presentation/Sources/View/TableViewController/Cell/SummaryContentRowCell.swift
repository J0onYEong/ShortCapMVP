import UIKit
import Domain

class SummaryContentRowCell: UITableViewCell {
    
    var videoDetail: VideoDetail?
    private var videoCode: VideoCode!
    
    var viewModel: SummaryContentViewModel!
    
    private var fetchingTask: Task<Void, Never>?
    
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

            thumbNailView.widthAnchor.constraint(equalToConstant: SFTableViewConfig.imageWidth),
            thumbNailView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            thumbNailView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            thumbNailView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
            
            titleLabel.leadingAnchor.constraint(equalTo: thumbNailView.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    func setUp(videoCode: VideoCode, viewModel: SummaryContentViewModel) {
        
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
                    case .success(let success):
                        
                        DispatchQueue.main.async {
                            
                            self.videoDetail = success
                            self.updateUI()
                            
                            // 인디케이터 종료
                            self.stopShowingIndicator()
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
}
