import UIKit
import Domain
import RxSwift
import RxRelay

enum VideoListViewConfig {
    
    // TableInset
    static let horizontalInset: CGFloat = 20
    
    // RowHeight
    static var rowHeight: CGFloat { thumbNailHeight }
    
    // ThumbNail
    static let thumbNailHeight: CGFloat = 160
    static let thumbNailWidth: CGFloat = 120
    static var thumbNailSize: CGSize { CGSize(width: thumbNailWidth, height: thumbNailHeight) }
}

class VideoListViewController: UIViewController {
    
    struct HashableVideoCellViewModel: Hashable, Equatable {
        
        static func == (lhs: VideoListViewController.HashableVideoCellViewModel, rhs: VideoListViewController.HashableVideoCellViewModel) -> Bool {
            lhs.viewModel.videoIdentity == rhs.viewModel.videoIdentity
        }
        
        var viewModel: VideoCellViewModelInterface
        
        init(_ viewModel: VideoCellViewModelInterface) {
            self.viewModel = viewModel
        }
        
        func hash(into hasher: inout Hasher) {
            
            hasher.combine(viewModel.videoIdentity)
        }
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, HashableVideoCellViewModel>
    
    public var insetsForFirstSection: UIEdgeInsets = .zero {
        
        didSet {
            
            videoListView.collectionViewLayout.invalidateLayout()
        }
    }
    
    private let videoListView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
          
        layout.scrollDirection = .vertical
          
        // 셀 간격 설정
        layout.minimumLineSpacing = 14.0
        layout.minimumInteritemSpacing = 0
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        view.isScrollEnabled = true
        
        // 인디케이터 설정
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = true
//        view.scrollIndicatorInsets = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 4)
        
        view.clipsToBounds = true
        view.register(VideoListViewCell.self, forCellWithReuseIdentifier: String(describing: VideoListViewCell.self))

        return view
    }()
    
    private var diffableDataSource: DataSource?
    
    private let disposebag = DisposeBag()
    
    init() {
        
        super.init(nibName: nil, bundle: nil)
        
        setCollectionView()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        
        [videoListView].forEach {
            
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        setUpAutoLayout()
    }
    
    private func setCollectionView() {
        
        videoListView.delegate = self
        
        let videoListViewCellId = String(describing: VideoListViewCell.self)
        
        videoListView.register(
            VideoListViewCell.self,
            forCellWithReuseIdentifier: videoListViewCellId
        )
        
        self.diffableDataSource = DataSource(
            collectionView: videoListView,
            cellProvider: { collectionView, indexPath, hashableViewModel in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: videoListViewCellId, for: indexPath) as? VideoListViewCell else { preconditionFailure() }
                
                cell.setUp(viewModel: hashableViewModel.viewModel)
                
            return cell
        })
    }
    
    public func setObservable(displayingVideos: Observable<[VideoCellViewModelInterface]>) {
        
        displayingVideos
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { [weak self] models in

                var snapshot = NSDiffableDataSourceSnapshot<Section, HashableVideoCellViewModel>()
                snapshot.appendSections([.main])
                snapshot.appendItems(models.map({ HashableVideoCellViewModel($0) }), toSection: .main)
                
                self?.diffableDataSource?.apply(snapshot, animatingDifferences: true)
            })
            .disposed(by: disposebag)
    }
    
    private func setUpAutoLayout() {
        
        NSLayoutConstraint.activate([
            videoListView.topAnchor.constraint(equalTo: view.topAnchor),
            videoListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoListView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension VideoListViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // TODO: 전면 수정예정
        
        if let cell = collectionView.cellForItem(at: indexPath) as? VideoListViewCell {
            
            let detail = cell.viewModel?.detail
            
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: VideoListViewController.self))
            
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            
            destinationVC.entity = detail
            
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: collectionView.bounds.width-VideoListViewConfig.horizontalInset*2, height: VideoListViewConfig.rowHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if section == 0 {
            return insetsForFirstSection
        }
        
        return .zero
    }
}
