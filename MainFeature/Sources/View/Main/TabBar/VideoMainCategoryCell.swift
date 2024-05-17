import UIKit
import RxSwift
import RxCocoa
import Domain
import DSKit

class VideoMainCategoryCell: UICollectionViewCell {
    
    private enum State { case focused, normal }
    
    private var category: VideoMainCategory?
    
    private var selectedMainCategory: BehaviorRelay<VideoMainCategory>?
    
    private var cellState: State = .normal
    
    private var isOvserverSettingFinished = false
    
    private let categoryLabel: PretendardLabel = {
       
        let labelView = PretendardLabel(text: "", fontSize: 16.0, fontWeight: .regular, isAutoResizing: true)
        
        labelView.isUserInteractionEnabled = false
        labelView.translatesAutoresizingMaskIntoConstraints = false
        
        return labelView
    }()
    
    private let categoryLabelBackground: UIView = {
       
        let view = UIView()
    
        // TODO: 다크모드진행시 수정사항
        view.layer.backgroundColor = UIColor.white.cgColor

        view.layer.masksToBounds = false
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let selectedBar: UIView = {
        
        let view = UIView()
        
        view.layer.backgroundColor = DSColor.mainBlue300.color.cgColor
        
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let selectedBarBoundary: UIView = {
        
        let view = UIView()
        
        view.backgroundColor = DSColor.black100.color
        view.clipsToBounds = true
        
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tabBarTouchEventFilter: UIView = {
        
        let view = UIView()
        
        view.backgroundColor = .lightGray.withAlphaComponent(0.5)
        view.alpha = 0.0
        
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let selectedBarAnimator: UIViewPropertyAnimator = {
        
        let manager = UIViewPropertyAnimator(duration: 0.3, curve: .easeOut)
        
        return manager
    }()
    
    private let tabBarButtonAnimator: UIViewPropertyAnimator = {
        
        let manager = UIViewPropertyAnimator(duration: 0.3, curve: .linear)
        
        return manager
    }()
    
    private static let selectedBarHeight: CGFloat = 2.0
    
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        categoryLabelBackground.addSubview(categoryLabel)
        selectedBarBoundary.addSubview(selectedBar)
        
        [
            categoryLabelBackground,
            selectedBarBoundary,
            tabBarTouchEventFilter,
        ].forEach {
            
            contentView.addSubview($0)
            $0.isUserInteractionEnabled = false
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tabBarIsTapped(_:)))
        
        contentView.addGestureRecognizer(tapGestureRecognizer)
        
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setAutoLayout() {
        
        NSLayoutConstraint.activate([
            
            tabBarTouchEventFilter.topAnchor.constraint(equalTo: contentView.topAnchor),
            tabBarTouchEventFilter.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tabBarTouchEventFilter.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tabBarTouchEventFilter.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Self.selectedBarHeight),
            
            categoryLabelBackground.topAnchor.constraint(equalTo: contentView.topAnchor),
            categoryLabelBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoryLabelBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            categoryLabelBackground.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Self.selectedBarHeight),
            
            categoryLabel.centerXAnchor.constraint(equalTo: categoryLabelBackground.centerXAnchor),
            categoryLabel.topAnchor.constraint(equalTo: categoryLabelBackground.topAnchor, constant: 3),
            categoryLabel.bottomAnchor.constraint(equalTo: categoryLabelBackground.bottomAnchor, constant: -3),
            
            selectedBarBoundary.heightAnchor.constraint(equalToConstant: Self.selectedBarHeight),
            selectedBarBoundary.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            selectedBarBoundary.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            selectedBarBoundary.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            selectedBar.heightAnchor.constraint(equalToConstant: Self.selectedBarHeight),
            selectedBar.leadingAnchor.constraint(equalTo: selectedBarBoundary.leadingAnchor),
            selectedBar.trailingAnchor.constraint(equalTo: selectedBarBoundary.trailingAnchor),
            selectedBar.topAnchor.constraint(equalTo: selectedBarBoundary.bottomAnchor),
        ])
    }
    
    public func setUp(category: VideoMainCategory, selectedMainCategory: BehaviorRelay<VideoMainCategory>) {
        
        self.category = category
        self.selectedMainCategory = selectedMainCategory
        categoryLabel.text = category.korName
        categoryLabel.textColor = DSColor.black300.color
        
        setObserver()
    }
    
    public func setObserver() {
        
        if isOvserverSettingFinished { return }
        
        isOvserverSettingFinished = true
        
        self.layoutIfNeeded()
        
        self.selectedMainCategory?
            .asDriver()
            .drive(onNext: { selectedMainCategory in
                
                let isFocused = selectedMainCategory.categoryId == self.category?.categoryId
                
                self.onTabEvent(isFocused ? .focused : .normal)
                
            })
            .disposed(by: disposeBag)
    }
    
    /// 선택된 상태에 호촐됩니다.
    private func onTabEvent(_ newState: State) {
        
        if cellState != newState {
            
            cellState = newState
            
            let isFocused = newState == .focused
            
            if isFocused {
                
                // 클릭된 상황에서만 애니메이션을 적용합니다.
                selectedBarAnimator.addAnimations { [weak self] in
                    
                    self?.categoryLabel.state = .focused
                    self?.selectedBar.layer.position.y = Self.selectedBarHeight * 0.5
                }
                
                if selectedBarAnimator.state == .active, selectedBarAnimator.isRunning {
                    
                    selectedBarAnimator.pauseAnimation()
                    
                    selectedBarAnimator.continueAnimation(withTimingParameters: UICubicTimingParameters(animationCurve: .linear), durationFactor: 0.3)
                }
                
                if selectedBarAnimator.state == .inactive {
                    
                    selectedBarAnimator.startAnimation()
                }
            } else {
                
                self.categoryLabel.state = .normal
                self.selectedBar.layer.position.y = Self.selectedBarHeight * 1.5
            }
        }
    }
}


// MARK: - Event
extension VideoMainCategoryCell {
    
    @objc func tabBarIsTapped(_ sender: UITapGestureRecognizer) {
        
        // 선택 이벤트 emit
        if let cellCategory = self.category {
            
            self.selectedMainCategory?.accept(cellCategory)
            
            if cellCategory.categoryId == VideoMainCategory.all.categoryId {
                
                NotificationCenter.mainFeature.post(name: .videoSubCategoryClicked, userInfo: [.videoFilter : VideoFilter.all])
            }
        }
        
        self.tabBarTouchEventFilter.alpha = 1.0
        
        tabBarButtonAnimator.addAnimations { [weak self] in
            
            self?.tabBarTouchEventFilter.alpha = 0.0
        }
        
        tabBarButtonAnimator.addCompletion { [weak self] _ in
            
            self?.tabBarTouchEventFilter.alpha = 0.0
        }
        
        // 애니메이션이 시작하지 않은 경우
        if tabBarButtonAnimator.state == .inactive, !tabBarButtonAnimator.isRunning {
            
            tabBarButtonAnimator.startAnimation()
        }
    }
}
