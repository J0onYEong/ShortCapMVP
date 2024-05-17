import UIKit
import Domain
import RxSwift
import RxCocoa

public class VideoListViewController: UIViewController {
    
    let videoListView: UICollectionView = {
        
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
        
        view.contentInset = .zero
        view.clipsToBounds = true
        view.register(VideoListViewCell.self, forCellWithReuseIdentifier: String(describing: VideoListViewCell.self))
        
        // 내부 컨텐츠 인셋
        view.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // ViewModel
    public let viewModel: VideoListViewModelInterface
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, VideoIdentity>
    
    private var diffableDataSource: DataSource?
    
    private let disposebag: DisposeBag = .init()

    public init(viewModel: VideoListViewModelInterface) {
        
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        self.view.addSubview(videoListView)
        
        // 오토레이아웃 설정
        setUpAutoLayout()
        
        // 컬렉션뷰 설정
        setCollectionView()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func viewDidLoad() {
        
    }
    
    func setUpAutoLayout() {
        
        NSLayoutConstraint.activate([
            videoListView.topAnchor.constraint(equalTo: view.topAnchor),
            videoListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoListView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func setCollectionView() {
        
        videoListView.delegate = self
        
        let videoListViewCellId = String(describing: VideoListViewCell.self)
        
        videoListView.register(
            VideoListViewCell.self,
            forCellWithReuseIdentifier: videoListViewCellId
        )
        
        self.diffableDataSource = DataSource(
            collectionView: videoListView,
            cellProvider: { collectionView, indexPath, item in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: videoListViewCellId, for: indexPath) as? VideoListViewCell else { preconditionFailure() }
                
            let viewModel = self.viewModel.filterdVideoCellViewModel.value.first(where: { $0.videoIdentity == item })!
                
            cell.setUp(viewModel: viewModel)
                
            return cell
        })
        
        viewModel
            .filterdVideoCellViewModel
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { models in

                var snapshot = NSDiffableDataSourceSnapshot<Section, VideoIdentity>()
                snapshot.appendSections([.main])
                snapshot.appendItems(models.map({ $0.videoIdentity }), toSection: .main)
                
                self.diffableDataSource?.apply(snapshot, animatingDifferences: false)
            })
            .disposed(by: disposebag)
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
            
            self.parent?.navigationController?.setNavigationBarHidden(false, animated: false)
            self.parent?.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Cell width를 컬랙션뷰와 같게한다 = 1열로 고정
        .init(width: collectionView.bounds.width-VideoCollectionViewConfig.horizontalInset*2, height: VideoCollectionViewConfig.rowHeight)
    }
}

