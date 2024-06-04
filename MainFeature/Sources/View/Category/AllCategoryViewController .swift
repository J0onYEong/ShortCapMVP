import UIKit
import Domain
import RxSwift
import RxRelay

class AllCatgoryViewController: UIViewController {
    
    private let videoListViewController = VideoListViewController()
    
    init(_ videoList: BehaviorRelay<[VideoCellViewModelInterface]>) {
        
        super.init(nibName: nil, bundle: nil)
        
        setVideoListViewController(videoList.asObservable())
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setVideoListViewController(_ videoList: Observable<[VideoCellViewModelInterface]>) {
        
        videoListViewController.setObservable(displayingVideos: videoList)
        videoListViewController.insetsForFirstSection = .init(top: 92, left: 20, bottom: 0, right: 20)
        
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
