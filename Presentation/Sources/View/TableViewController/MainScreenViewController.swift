import UIKit
import Domain
import RxSwift
import RxCocoa

public class MainScreenViewController: UIViewController {
    
    let collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
          
        layout.scrollDirection = .vertical
          
        // 셀 간격 설정
        layout.minimumLineSpacing = 14.0
        layout.minimumInteritemSpacing = 0
       
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        view.backgroundColor = .white
        
        view.isScrollEnabled = true
        
        // 인디케이터 설정
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = true
//        view.scrollIndicatorInsets = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 4)
        
        view.contentInset = .zero
        view.clipsToBounds = true
        view.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: VideoCollectionViewCell.self))
        
        // 내부 컨텐츠 인셋
        view.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // ViewModel
    public let viewModel: VideoCollectionViewModel
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, DefaultVideoCellViewModel>
    
    private var diffableDataSource: DataSource?
    
    private let disposebag: DisposeBag = .init()

    public init(viewModel: VideoCollectionViewModel) {
        
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public override func viewDidLoad() {
        
        // 오토레이아웃 설정
        setUpAutoLayout()
        
        // 컬렉션뷰 설정
        configureTableView()
    }
    
    func setUpAutoLayout() {
        
        self.view.addSubview(collectionView)
        
        self.view.layer.backgroundColor = UIColor.white.cgColor
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func configureTableView() {
        
        collectionView.delegate = self
        
        collectionView.register(
            VideoCollectionViewCell.self,
            forCellWithReuseIdentifier: String(describing: VideoCollectionViewCell.self)
        )
        
        self.diffableDataSource = DataSource(
            collectionView: self.collectionView,
            cellProvider: { collectionView, indexPath, item in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: VideoCollectionViewCell.self), for: indexPath) as? VideoCollectionViewCell else { preconditionFailure() }
                
            cell.setUp(viewModel: item)
                
            return cell
        })
        
        viewModel
            .displayCellViewModel
            .map({ $0.sorted { lhs, rhs in lhs.detail.createdAt > rhs.detail.createdAt } })
            .asDriver(onErrorJustReturn: [])
            .drive(onNext: { models in

                guard let vms = models as? [DefaultVideoCellViewModel] else { fatalError() }

                var snapshot = NSDiffableDataSourceSnapshot<Section, DefaultVideoCellViewModel>()
                snapshot.appendSections([.main])
                snapshot.appendItems(vms, toSection: .main)
                
                self.diffableDataSource?.apply(snapshot, animatingDifferences: true)
            })
            .disposed(by: disposebag)
    }
}

extension MainScreenViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? VideoCollectionViewCell {
            
            let detail = cell.viewModel.detail
            
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: MainScreenViewController.self))
            
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            
            destinationVC.entity = detail
            
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Cell width를 컬랙션뷰와 같게한다 = 1열로 고정
        .init(width: collectionView.bounds.width-VideoCollectionViewConfig.horizontalInset*2, height: VideoCollectionViewConfig.rowHeight)
    }
}
