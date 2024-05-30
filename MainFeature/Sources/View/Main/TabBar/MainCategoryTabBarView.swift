import UIKit
import RxSwift
import RxRelay
import Domain
import Data
import DSKit

internal enum TabBarConfig {
    
    static let movingBarHeight = 2.0
    static let cellSize: CGSize = {
       
        let width = UIScreen.main.bounds.width / 7.0
        let height = 28.0
        
        return .init(width: width, height: height)
    }()
}

class MainCategoryTabBarView: UIScrollView {
    
    private var mainCategories: [VideoMainCategory] = []
    
    private let selectedMainCategory: BehaviorRelay<VideoMainCategory>
    
    // MARK: - 제스쳐 관련
    enum MovingDirection {
        case right
        case left
        case center
    }
    public weak var gestureArea: UIView?
    
    var gestureBeganPosition: CGPoint = .init()
    var barBeginPosition: CGPoint = .init()
    var selectedCellIndex = BehaviorRelay<Int>(value: 0)
    
    var movingDirec: MovingDirection = .center
    var maxBarMovingDistance: CGFloat = 70
    let minimumGestureDistance: CGFloat = 40
    
    private let movingBar: UIView = {
        
        let view = UIView()
        
        view.backgroundColor = DSColor.mainBlue300.color
        view.isUserInteractionEnabled = false
        
        return view
    }()
    
    private let movingBarBackground: UIView = {
        let view = UIView()
        
        view.backgroundColor = DSColor.black100.color
        view.isUserInteractionEnabled = false
        
        return view
    }()
    
    private let stackView: UIStackView = {
        
        let stack = UIStackView()
        
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
       
        return stack
    }()
    
    private let disposeBag = DisposeBag()
    
    init(selectedMainCategory: BehaviorRelay<VideoMainCategory>) {
        
        self.selectedMainCategory = selectedMainCategory
        
        super.init(frame: .zero)
        
        self.backgroundColor = .clear
        self.showsHorizontalScrollIndicator = false
        
        [stackView, movingBarBackground, movingBar].forEach {
            
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        movingBar.frame = .init(
            x: 0,
            y: TabBarConfig.cellSize.height-TabBarConfig.movingBarHeight,
            width: TabBarConfig.cellSize.width,
            height: TabBarConfig.movingBarHeight
        )
        
        setAutoLayout()
        
        setObserver()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    public func setTabBarView(mainCategories: [VideoMainCategory]) {
        
        self.mainCategories = mainCategories
        
        mainCategories.enumerated().forEach { (index, mainCategory) in
            
            let cellView = MainCategoryTabBarCellView(
                cellIndexForTabBarView: index,
                mainCategory: mainCategory,
                selectedCellIndex: selectedCellIndex,
                selectedMainCategory: selectedMainCategory,
                cellSize: TabBarConfig.cellSize
            )
            
            cellView.categoryLabel.text = mainCategory.korName
            
            self.stackView.addArrangedSubview(cellView)
        }
    }
    
    public func setGesture(gestureArea: UIView) {
        
        if let recognizer = gestureArea.gestureRecognizers?.first(where: { ($0 as? UIPanGestureRecognizer) != nil }) {
            
            recognizer.addTarget(self, action: #selector(onGestureRecognized(_:)))
        }
        
        self.gestureArea = gestureArea
    }
    
    private func setObserver() {
        
        selectedCellIndex
            .scan((0, 0)) { ($0.1, $1) }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (previousIndex, currentIndex) in
                
                self?.moveBar(previousIndex: previousIndex, currentIndex: currentIndex)
            })
            .disposed(by: disposeBag)
    }
    
    private func setAutoLayout() {
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: TabBarConfig.cellSize.height),
            
            movingBarBackground.topAnchor.constraint(equalTo: self.topAnchor, constant: TabBarConfig.cellSize.height-TabBarConfig.movingBarHeight),
            movingBarBackground.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            movingBarBackground.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            movingBarBackground.heightAnchor.constraint(equalToConstant: TabBarConfig.movingBarHeight),
        ])
    }
}

extension MainCategoryTabBarView {
    
    @objc
    func onGestureRecognized(_ gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            
            barBeginPosition = movingBar.frame.origin
            
            gestureBeganPosition = gesture.numberOfTouches > 0 ? gesture.location(ofTouch: 0, in: gestureArea) : .zero
            
        case .changed:
            
            let currentTouchPos = gesture.numberOfTouches > 0 ? gesture.location(ofTouch: 0, in: gestureArea) : .zero
            
            let movingDis = abs(gestureBeganPosition.x-currentTouchPos.x)
            
            if movingDis >= minimumGestureDistance {
                
                movingDirec = gestureBeganPosition.x-currentTouchPos.x < 0 ? .left : .right
                
            } else {
                
                movingDirec = .center
            }
            
            let movedVector = gesture.translation(in: gestureArea)
            
            let d = 0.14
            
            movingBar.frame.origin.x -= movedVector.x * d
            
            gesture.setTranslation(.zero, in: gestureArea)
            
            // 좌측 이동 제한
            if movingBar.frame.origin.x < 0 {
                
                movingDirec = .center
                
                movingBar.frame.origin.x = .zero
            }
            // 우측 최대 이동 제한
            let maxXPoint = CGFloat(mainCategories.count-1) * TabBarConfig.cellSize.width
            if movingBar.frame.origin.x > maxXPoint {
                
                movingDirec = .center
                
                movingBar.frame.origin.x = maxXPoint
            }

        case .ended, .cancelled:
            
            let previousIndex = selectedCellIndex.value
            
            // 인덱스 이동
            if [.right, .left].contains(where: { movingDirec == $0 }) {
                
                var nextIndex = previousIndex + (movingDirec == .right ? 1 : -1)
                
                if mainCategories.count <= nextIndex { nextIndex = mainCategories.count-1 }
                if nextIndex < 0 { nextIndex = 0 }
                
                // 선택된 셀을 전달한다, bar연산을 계산한다.
                selectedCellIndex.accept(nextIndex)
                
                // 필터링을 위한 옵저버블
                selectedMainCategory.accept(mainCategories[nextIndex])
                
            } else {
                
                // 원래 자리로 복귀
                moveBar(previousIndex: previousIndex, currentIndex: previousIndex)
            }
            
        default:
            return
        }
    }
    
    // cellIndex가 결정된 이후에 호출해야함
    func moveBar(previousIndex: Int, currentIndex: Int) {
        
        let startXPosition: CGFloat = TabBarConfig.cellSize.width * CGFloat(previousIndex)
        
        // 하단바 이동 애니메이션
        UIView.animate(withDuration: 0.3) {
            
            self.movingBar.frame.origin.x = startXPosition + TabBarConfig.cellSize.width * CGFloat(currentIndex-previousIndex)
        }
        
        // MARK: - 셀위를 움직이는 바가 현재 화면을 이탈하는 경우 처리
        let screenWidth = self.bounds.width
        
        let barPadding: CGFloat = 10.0
        
        // 이동바가 오른쪽 화면을 이탈한 경우
        if self.contentOffset.x+screenWidth < movingBar.frame.origin.x + TabBarConfig.cellSize.width + barPadding {
            
            let rightBottomXPos = CGFloat(currentIndex+1 + (currentIndex < mainCategories.count-1 ? 1 : 0) ) * TabBarConfig.cellSize.width
            
            let scrollViewXOffset = rightBottomXPos - screenWidth
            
            self.setContentOffset(.init(x: scrollViewXOffset, y: 0), animated: true)
        }
        
        // 이동바가 왼쪽 화면을 이탈한 경우
        if self.contentOffset.x > movingBar.frame.origin.x - barPadding {
            
            let leftBottomXPos = CGFloat(currentIndex - (currentIndex > 0 ? 1 : 0) ) * TabBarConfig.cellSize.width
            
            let scrollViewXOffset = leftBottomXPos
            
            self.setContentOffset(.init(x: scrollViewXOffset, y: 0), animated: true)
        }
    }
}


class MainCategoryTabBarCellView: UIView {
    
    private enum State { case focused, normal }
    
    private var cellState: State = .normal
    
    private let cellIndex: Int
    
    private let mainCategory: VideoMainCategory
    
    private(set) var cellSize: CGSize
    
    private let selectedCellIndex: BehaviorRelay<Int>
    private let selectedMainCategory: BehaviorRelay<VideoMainCategory>
    
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
        mainCategory: VideoMainCategory,
        selectedCellIndex: BehaviorRelay<Int>,
        selectedMainCategory: BehaviorRelay<VideoMainCategory>,
        cellSize: CGSize
    ) {
        
        self.cellIndex = cellIndexForTabBarView
        self.mainCategory = mainCategory
        self.selectedCellIndex = selectedCellIndex
        self.selectedMainCategory = selectedMainCategory
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
        
        selectedMainCategory
            .asDriver()
            .drive(onNext: { selectedMainCategory in
                
                let isFocused = selectedMainCategory.categoryId == self.mainCategory.categoryId
                
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
        self.selectedMainCategory.accept(mainCategory)
        
        // 선택된 셀 인덱스를 emit
        self.selectedCellIndex.accept(cellIndex)
        
        // MARK: - 클릭 이벤트 애니메이션
        self.touchEffectView.alpha = 1.0
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            
            self?.touchEffectView.alpha = 0.0
            
        } completion: { [weak self] _ in
            
            self?.touchEffectView.alpha = 0.0
        }
    }
}

