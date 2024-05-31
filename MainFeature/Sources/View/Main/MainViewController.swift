import UIKit
import RxSwift
import RxCocoa
import Domain
import DSKit


public class MainViewController: UIViewController {
    
    private let mainViewModel: MainViewModel
    public let videoListViewModel: VideoListViewModelInterface
    
    private let applicationLogo: UIView = {
        
        let imageView = UIImageView()
        
        imageView.image = UIImage(named: "shortCapLogo", in: Bundle(for: MainViewController.self), with: nil)
        
        imageView.contentMode = .scaleAspectFit
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let view = UIView()
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        return view
    }()
    
    private let indicator: UIView = {
       
        let indicatorBackgroundView = UIView()
        
        let indicator = UIActivityIndicatorView()
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        indicator.startAnimating()
        
        indicatorBackgroundView.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.widthAnchor.constraint(equalToConstant: 75),
            indicator.centerXAnchor.constraint(equalTo: indicatorBackgroundView.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: indicatorBackgroundView.centerYAnchor),
        ])
        
        indicatorBackgroundView.backgroundColor = .lightGray.withAlphaComponent(0.25)
        
        indicatorBackgroundView.alpha = 0.0
        
        return indicatorBackgroundView
    }()
    
    private let tempSearchView: UIView = {
        
        let searchView = UIView()
        
        searchView.backgroundColor = DSColor.black100.color
        searchView.layer.cornerRadius = 7.38
        
        let label = PretendardLabel(text: "저장했던 숏폼을 키워드로 검색해보세요!", fontSize: 13, fontWeight: .regular)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        searchView.addSubview(label)
        
        NSLayoutConstraint.activate([
            
            label.centerYAnchor.constraint(equalTo: searchView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: searchView.leadingAnchor, constant: 18),
        ])
        
        return searchView
    }()
    
    private let mainCategoryTabBarView: MainCategoryTabBarView!
    
    private let mainScrollView: UIScrollView = {
       
        let scrollView = UIScrollView()
        
        scrollView.isScrollEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
        
        return scrollView
    }()
    
    private let mainStackView: UIStackView = {
        
        let stack = UIStackView()
        
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
       
        return stack
    }()
    
    private let pageTransitionGestureRecognizer = UIPanGestureRecognizer()
    
    private let gestureArea: UIView = {
       
        let view = UIView()
        
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let disposeBag = DisposeBag()
    
    public init(mainViewModel: MainViewModel, videoListViewModel: VideoListViewModelInterface) {
        
        self.mainViewModel = mainViewModel
        self.videoListViewModel = videoListViewModel
        self.mainCategoryTabBarView = MainCategoryTabBarView(selectedMainCategoryIndex: mainViewModel.selectedMainCategoryIndex)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) { fatalError() }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        [
            applicationLogo,
            mainCategoryTabBarView,
            gestureArea,
            indicator
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // gestureArea위에 존재하는 뷰
        [mainScrollView, tempSearchView].forEach {
            gestureArea.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // 메인 스크롤뷰
        [mainStackView].forEach {
            mainScrollView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // 제스처 인식기 설정
        pageTransitionGestureRecognizer.addTarget(self, action: #selector(onPageTransitionGestureRecognized(_:)))
        gestureArea.addGestureRecognizer(pageTransitionGestureRecognizer)
        mainCategoryTabBarView.setGesture(gestureArea: gestureArea)
        
        // 인디케이터 가동
        showUpIndicator()
        
        // 옵저버 세팅
        setObserver()
        mainViewModel.fetchCategories()
        
        // 탭바, 인디케이터 오토레이아웃
        setAutoLayout()
    }
    
    private func setObserver() {
        
        let categoryViewControllersAreAvailable = PublishSubject<Bool>()
        let tabBarIsAvailable = PublishSubject<Bool>()
        
        Observable
            .combineLatest([categoryViewControllersAreAvailable, tabBarIsAvailable])
            .subscribe(onNext: { [weak self] in
                
                if !$0.contains(where: { $0 == false }) {
                    
                    self?.dismissIndicator()
                }
            })
            .disposed(by: disposeBag)
        
        // MainCategory -> ViewModel
        mainViewModel
            .mainCategories
            .take(1)
            .observe(on: MainScheduler.instance)
            .map { [unowned self] mainCategories in
                
                return mainCategories.compactMap { mainCategory in
                    
                    if mainCategory == .all {
                        
                        let viewController = AllCatgoryViewController(self.videoListViewModel.displayingVideoCellViewModel)
                        self.insertCategoryViewController(viewController)
                        return nil
                    }
                    
                    let mainCategoryViewModel = self.mainViewModel.videoMainCategoryViewModelFactory.create(
                        mainCategory: mainCategory,
                        videoList: videoListViewModel.displayingVideoCellViewModel
                    )
                    
                    mainCategoryViewModel.selectedSubCategory = self.mainViewModel.selectedSubCategory
                    
                    return mainCategoryViewModel
                }
            }
            .subscribe(onNext: { [unowned self] (viewModels: [VideoMainCategoryViewModel]) in
                
                // 메인카테고리가 전체가 이닌 경우 뷰컨트롤러 삽입
                viewModels.forEach { viewModel in
                    
                    let viewController = self.mainViewModel.mainCategoryViewControllerFactory.create(viewModel: viewModel)
                    self.insertCategoryViewController(viewController)
                }
                
                categoryViewControllersAreAvailable.onNext(true)
            })
            .disposed(by: disposeBag)
        
        // 메인 카테고리 탭바 구성
        mainViewModel
            .mainCategories
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] mainCategories in
                
                if mainCategories.isEmpty { return }
                
                self.mainCategoryTabBarView.setTabBarView(mainCategories: mainCategories)
                
                tabBarIsAvailable.onNext(true)
            })
            .disposed(by: disposeBag)
        
    
        // 화면 스와이프 이벤트 발생
        Observable.combineLatest(
            mainViewModel.mainCategories,
            mainViewModel.selectedMainCategoryIndex
        )
        .subscribe(onNext: { (mainCategories, mainCategoryIndex) in
        
            let selectedMainCategory = mainCategories[mainCategoryIndex]
            
            if selectedMainCategory == .all {
                
                // 전체 비디오 리스트
                
            } else {
                
                // 카테고리
            }
        })
        .disposed(by: disposeBag)

    }

    private func setAutoLayout() {
        
        // MainViewController의 서브뷰
        NSLayoutConstraint.activate([
            
            indicator.topAnchor.constraint(equalTo: view.topAnchor),
            indicator.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            indicator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            indicator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            applicationLogo.heightAnchor.constraint(equalToConstant: 56.0),
            applicationLogo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            applicationLogo.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            applicationLogo.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            mainCategoryTabBarView.heightAnchor.constraint(equalToConstant: 28.0),
            mainCategoryTabBarView.topAnchor.constraint(equalTo: applicationLogo.bottomAnchor),
            mainCategoryTabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainCategoryTabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            gestureArea.topAnchor.constraint(equalTo: mainCategoryTabBarView.bottomAnchor),
            gestureArea.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gestureArea.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gestureArea.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        // 제스쳐 영역 서브뷰
        NSLayoutConstraint.activate([
        
            tempSearchView.topAnchor.constraint(equalTo: gestureArea.topAnchor, constant: 20),
            tempSearchView.leadingAnchor.constraint(equalTo: gestureArea.leadingAnchor, constant: 20),
            tempSearchView.trailingAnchor.constraint(equalTo: gestureArea.trailingAnchor, constant: -20),
            tempSearchView.heightAnchor.constraint(equalToConstant: 52),
            
            mainScrollView.topAnchor.constraint(equalTo: gestureArea.topAnchor),
            mainScrollView.leadingAnchor.constraint(equalTo: gestureArea.leadingAnchor),
            mainScrollView.trailingAnchor.constraint(equalTo: gestureArea.trailingAnchor),
            mainScrollView.bottomAnchor.constraint(equalTo: gestureArea.bottomAnchor),
        ])
        
        // MainScrollView뷰의 서브뷰
        NSLayoutConstraint.activate([
        
            mainStackView.topAnchor.constraint(equalTo: mainScrollView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor),
        ])
    }
    
    private func showUpIndicator() {
        
        view.bringSubviewToFront(indicator)
        indicator.alpha = 1.0
    }
    
    private func dismissIndicator() {
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            
            self?.indicator.alpha = 0.0
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func insertCategoryViewController(_ viewController: UIViewController) {
        
        // willMove를 자동으로 호출한다.
        
        // 현재 뷰컨트롤러의 자식뷰컨트롤러를 지정하는 경우에 호출된다
        self.addChild(viewController)
        
        // ✅ 커스텀 컨테이너 구현시, addChild이후에 반드시 호출해야한다.
        viewController.didMove(toParent: self)
        
        let categoryView: UIView = viewController.view
        
        categoryView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.addArrangedSubview(categoryView)
        
        NSLayoutConstraint.activate([
            categoryView.heightAnchor.constraint(equalTo: mainScrollView.heightAnchor),
            categoryView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor),
        ])
    }
    
}

extension MainViewController {
    
    @objc
    func onPageTransitionGestureRecognized(_ gesture: UIPanGestureRecognizer) {
        
        
        
    }
}
