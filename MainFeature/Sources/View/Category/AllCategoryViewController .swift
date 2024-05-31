import UIKit
import Domain
import RxSwift
import RxRelay

class AllCatgoryViewController: UIViewController {
    
    init(_ videoList: BehaviorRelay<[VideoCellViewModelInterface]>) {
        
        super.init(nibName: nil, bundle: nil)
        
        setVideoListViewController(videoList.asObservable())
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setVideoListViewController(_ videoList: Observable<[VideoCellViewModelInterface]>) {
        let videoListViewController = VideoListViewController2(
            displayingVideos: videoList
        )
        
        self.addChild(videoListViewController)
        
        let videoListView: UIView = videoListViewController.view
        videoListView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(videoListView)
        
        NSLayoutConstraint.activate([
            
            videoListView.topAnchor.constraint(equalTo: view.topAnchor),
            videoListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoListView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    override func viewDidLoad() {
        
    }
}
