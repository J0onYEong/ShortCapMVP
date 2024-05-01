import UIKit
import Domain
import RxSwift
import RxCocoa

public class MainScreenViewController: UIViewController {
    
    let videoCollectionView: UICollectionView = {
        
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
    public let viewModel: VideoTableViewModel
    
    // ViewController
    public init(viewModel: VideoTableViewModel) {
        
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        
        // 오토레이아웃 설정
        setUpAutoLayout()
        
        // 컬렉션뷰 설정
        configureTableView()
        
        // 옵저버블과 테이블셀 바인딩
        viewModel.bindWith(collectionView: videoCollectionView)
    }
}

extension MainScreenViewController {
    
    func setUpAutoLayout() {
        
        self.view.addSubview(videoCollectionView)
        
        self.view.layer.backgroundColor = UIColor.white.cgColor
        
        NSLayoutConstraint.activate([
            videoCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            videoCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func configureTableView() {
        
        videoCollectionView.delegate = self
    }
}

extension MainScreenViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let cell = collectionView.cellForItem(at: indexPath) as? VideoCollectionViewCell {
            
            if let detail = cell.videoDetail {
                
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle(for: MainScreenViewController.self))
                
                let destinationVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                
                destinationVC.entity = detail
                
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Cell width를 컬랙션뷰와 같게한다 = 1열로 고정
        .init(width: collectionView.bounds.width-VideoCollectionRowConfig.horizontalInset*2, height: VideoCollectionRowConfig.rowHeight)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let rowCell = cell as? VideoCollectionViewCell {
            
            rowCell.getDetail()
        }
    }
}
