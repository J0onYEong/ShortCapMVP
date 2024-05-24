import UIKit
import DSKit
import RxSwift
import RxCocoa
import Domain

public class MainCategoryViewController: UIViewController {
    
    public let viewModel: VideoMainCategoryViewModel
    
    private let subCategoryCollectionView: UICollectionView = {
       
        let layout = UICollectionViewFlowLayout()
          
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 14.0
        layout.minimumInteritemSpacing = 0
       
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.isScrollEnabled = true
        
        let horizontalInset = VideoCollectionViewConfig.horizontalInset
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.clipsToBounds = true
        
        return collectionView
    }()
    
    private let disposeBag = DisposeBag()
    
    public init(viewModel: VideoMainCategoryViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        setCollectionView()
    }
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        [subCategoryCollectionView].forEach {
            
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setAutoLayout()
    }
    
    private func setCollectionView() {
        
        subCategoryCollectionView.delegate = self
        
        let subCategoryCellID = String(describing: SubCategoryCollectionViewCell.self)
        
        subCategoryCollectionView.register(SubCategoryCollectionViewCell.self, forCellWithReuseIdentifier: subCategoryCellID)
        
        viewModel.subCategories
            .asDriver()
            .drive(subCategoryCollectionView.rx.items(cellIdentifier: subCategoryCellID, cellType: SubCategoryCollectionViewCell.self)) { index, subCategory, cell in
                
                let viewModel = self.viewModel.subCategoryCellViewModelFactory.create(
                    mainCategory: self.viewModel.category,
                    subCategory: subCategory
                )
                    
                cell.setUp(subCategoryCellViewModel: viewModel)
            }
            .disposed(by: disposeBag)
    }
    
    private func setAutoLayout() {
        
        NSLayoutConstraint.activate([
            
            subCategoryCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            subCategoryCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subCategoryCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subCategoryCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension MainCategoryViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Cell width를 컬랙션뷰와 같게한다 = 1열로 고정
        .init(width: collectionView.bounds.width-VideoCollectionViewConfig.horizontalInset*2, height: VideoCollectionViewConfig.rowHeight)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let subCategoryCell = collectionView.cellForItem(at: indexPath) as? SubCategoryCollectionViewCell {
            
            guard let cellSubCategory = subCategoryCell.viewModel?.subCategory else { return }
            
            // 선택된 서브카테고리 전달
            viewModel.selectedSubCategory?.accept(cellSubCategory)
        }
    }
}
