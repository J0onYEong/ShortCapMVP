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
    
    private let selectedMainCategoryIndex: BehaviorRelay<Int>
    
    // MARK: - 제스쳐 관련
    enum MovingDirection {
        case right
        case left
        case center
    }
    public weak var gestureArea: UIView?
    
    var gestureBeganPosition: CGPoint = .init()
    var barBeginPosition: CGPoint = .init()
    
    var movingDirec: MovingDirection = .center
    var maxBarMovingDistance: CGFloat = 70
    let minimumGestureDistance: CGFloat = 50
    
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
    
    init(selectedMainCategoryIndex: BehaviorRelay<Int>) {
        
        self.selectedMainCategoryIndex = selectedMainCategoryIndex
        
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
                selectedMainCategoryIndex: selectedMainCategoryIndex,
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
        
        selectedMainCategoryIndex
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
            
            let previousIndex = selectedMainCategoryIndex.value
            
            // 인덱스 이동
            if [.right, .left].contains(where: { movingDirec == $0 }) {
                
                var nextIndex = previousIndex + (movingDirec == .right ? 1 : -1)
                
                if mainCategories.count <= nextIndex { nextIndex = mainCategories.count-1 }
                if nextIndex < 0 { nextIndex = 0 }
                
                // 선택된 셀을 전달한다, bar연산을 계산한다.
                selectedMainCategoryIndex.accept(nextIndex)
                
            } else {
                
                selectedMainCategoryIndex.accept(previousIndex)
                
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
        UIView.animate(withDuration: 0.3) { [weak self] in
            
            self?.movingBar.frame.origin.x = startXPosition + TabBarConfig.cellSize.width * CGFloat(currentIndex-previousIndex)
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
