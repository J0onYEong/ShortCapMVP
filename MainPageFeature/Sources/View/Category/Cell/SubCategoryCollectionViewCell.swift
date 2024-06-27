import UIKit
import DSKit
import RxSwift
import RxCocoa
import Domain

public class SubCategoryCollectionViewCell: UICollectionViewCell {
    
    public var viewModel: SubCategoryCellViewModel?
    
    private let thumbNailView: UIView = {
        
        // TODO: 썸네일 선정이후 수정예정
        
        let imageView = UIView()
        
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 5.0
        imageView.clipsToBounds = true
        
        let label = UILabel()
        label.text = "TEST"
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
        ])
        
        return imageView
    }()
    
    private let titleLabel: PretendardLabel = {
       
        let labelView = PretendardLabel(text: "", fontSize: 20.0, fontWeight: .bold, isAutoResizing: true)
        
        labelView.textAlignment = .left
        
        return labelView
    }()
    
    private let countLabel: PartHighLightLabel = {
       
        let labelView = PartHighLightLabel(text: "", size: 13, range: .init())
        
        labelView.textAlignment = .left
        
        return labelView
    }()
    
    private var isObserverSet = false
    
    private let disposeBag = DisposeBag()
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        
        [thumbNailView, titleLabel, countLabel].forEach {
            
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        setAutoLayout()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    private func setAutoLayout() {
        
        NSLayoutConstraint.activate([
            
            thumbNailView.widthAnchor.constraint(equalToConstant: 120),
            thumbNailView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbNailView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbNailView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: thumbNailView.trailingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            
            countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            countLabel.leadingAnchor.constraint(equalTo: thumbNailView.trailingAnchor, constant: 15),
            countLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
        ])
    }
    
    public func setUp(subCategoryCellViewModel viewModel: SubCategoryCellViewModel) {
        
        self.viewModel = viewModel
        
        titleLabel.text = viewModel.subCategory.name
        
        // TODO: 이미지 설정
        
        setObserver()
    }
    
    private func setObserver() {
        
        NotificationCenter.videoCategoryMappingResult
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] information in

                if let main = self?.viewModel?.mainCategory.categoryId, 
                    let sub = self?.viewModel?.subCategory.categoryId,
                    let videoCount = information[main]?[sub]?.count{
                    
                    let hightLigtText = "\(videoCount)개"
                    
                    self?.countLabel.apply(text: "총 \(hightLigtText)의 숏폼을 저장했어요!", part: hightLigtText)
                    
                    
                    // TODO: 가장 최근 추가날짜(해당 서브카테고리)
                } else {
                    
                    let hightLigtText = "비어있어요!"
                    
                    self?.countLabel.apply(text: "카테고리가 \(hightLigtText)", part: hightLigtText)
                }
            })
            .disposed(by: disposeBag)
            
    }
}
