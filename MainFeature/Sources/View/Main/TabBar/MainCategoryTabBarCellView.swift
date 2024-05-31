import UIKit
import RxRelay
import RxSwift
import DSKit

class MainCategoryTabBarCellView: UIView {
    
    private enum State { case focused, normal }
    
    private let cellIndex: Int
    
    private let selectedMainCategoryIndex: BehaviorRelay<Int>
    
    private(set) var cellSize: CGSize
    
    private var cellState: State = .normal
    
    public let categoryLabel: PretendardLabel = {
       
        let labelView = PretendardLabel(text: "", fontSize: 16.0, fontWeight: .regular, isAutoResizing: true)
        
        labelView.isUserInteractionEnabled = false
        labelView.translatesAutoresizingMaskIntoConstraints = false
        
        return labelView
    }()
    
    private let touchEffectView: UIView = {
        
        let view = UIView()
        
        view.backgroundColor = .lightGray.withAlphaComponent(0.5)
        view.alpha = 0.0
        
        view.isUserInteractionEnabled = false
        
        return view
    }()
    
    private let disposeBag = DisposeBag()
    
    init(
        cellIndexForTabBarView: Int,
        selectedMainCategoryIndex: BehaviorRelay<Int>,
        cellSize: CGSize
    ) {
        
        self.cellIndex = cellIndexForTabBarView
        self.selectedMainCategoryIndex = selectedMainCategoryIndex
        self.cellSize = cellSize
        
        super.init(frame: .zero)
        
        self.backgroundColor = .white
        
        [categoryLabel, touchEffectView].forEach {
            
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(cellIsTapped(_:)))
        
        self.addGestureRecognizer(tapGestureRecognizer)
        
        setAutoLayout()
        
        setObserver()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    override var intrinsicContentSize: CGSize { cellSize }
    
    private func setAutoLayout() {
        
        NSLayoutConstraint.activate([
            
            categoryLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            categoryLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 3),
            categoryLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -(3+TabBarConfig.movingBarHeight)),
        
            touchEffectView.topAnchor.constraint(equalTo: self.topAnchor),
            touchEffectView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            touchEffectView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            touchEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    private func setObserver() {
        
        selectedMainCategoryIndex
            .asDriver()
            .drive(onNext: { index in
                
                let isFocused = index == self.cellIndex
                
                self.onMainCategoryIsSeleceted(isFocused ? .focused : .normal)
                
            })
            .disposed(by: disposeBag)
    }
    
    // 셀의 상태에 따른 UI변화
    private func onMainCategoryIsSeleceted(_ newState: State) {
        
        if cellState != newState {
            
            cellState = newState
            
            let isFocused = newState == .focused
            
            UIView.animate(withDuration: 0.3) {
                
                self.categoryLabel.state = isFocused ? .focused : .normal
            }
        }
    }
    
    // 현재 셀이 선택됬을 때 호출
    @objc func cellIsTapped(_ sender: UITapGestureRecognizer) {
        
        // 선택된 메인카테고리를 emit
        self.selectedMainCategoryIndex.accept(cellIndex)
        
        // MARK: - 클릭 이벤트 애니메이션
        self.touchEffectView.alpha = 1.0
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            
            self?.touchEffectView.alpha = 0.0
            
        } completion: { [weak self] _ in
            
            self?.touchEffectView.alpha = 0.0
        }
    }
}

