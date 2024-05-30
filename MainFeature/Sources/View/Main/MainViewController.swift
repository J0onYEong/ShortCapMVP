import UIKit
import RxSwift
import RxCocoa
import Domain
import DSKit


public class MainViewController: UIViewController {
    
    private let mainViewModel: MainViewModel
    private let videoListViewModel: VideoListViewModelInterface
    
    public var videoListViewController: VideoListViewController
    
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
    
    private let mainCategoryTabBarView: MainCategoryTabBarView!
    
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
    
    private let pageTransitionGestureRecognizer = UIPanGestureRecognizer()
    
    let gestureArea: UIView = {
       
        let view = UIView()
        
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let disposeBag = DisposeBag()
    
    public init(mainViewModel: MainViewModel, videoListViewModel: VideoListViewModelInterface) {
        
        self.mainViewModel = mainViewModel
        self.videoListViewModel = videoListViewModel
        self.videoListViewController = VideoListViewController(viewModel: videoListViewModel)
        self.mainCategoryTabBarView = MainCategoryTabBarView(selectedMainCategory: mainViewModel.selectedMainCategory)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) { fatalError() }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        [gestureArea, indicator, applicationLogo, mainCategoryTabBarView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // gestureArea위에 존재하는 뷰
        [tempSearchView].forEach {
            gestureArea.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        
        // 제스처 인식기 설정
        pageTransitionGestureRecognizer.addTarget(self, action: #selector(onPageTransitionGestureRecognized(_:)))
        gestureArea.addGestureRecognizer(pageTransitionGestureRecognizer)
        mainCategoryTabBarView.setGesture(gestureArea: gestureArea)
        
        // 탭바, 인디케이터 오토레이아웃
        setAutoLayout()
        
        // 비디오 리스트 뷰컨트롤러
        setVideoListViewController()
        
        // 인디케이터 가동
        showUpIndicator()
        
        // 옵저버 설정
        setObserver()
    }
    
    private func setVideoListViewController() {
        
        self.addChild(videoListViewController)
        
        videoListViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(videoListViewController.view)
        
        view.bringSubviewToFront(videoListViewController.view)
        
        NSLayoutConstraint.activate([
            
            videoListViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            videoListViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoListViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    private func setObserver() {
        
        // 서브카테고리가 선택(핫)됬을 때, 비디오 리스트를 표출
        mainViewModel
            .selectedSubCategory
            .asSignal()
            .emit(onNext: { subCategory in
                
                self.showVideoListView()
            })
            .disposed(by: disposeBag)
        
        // 비디오 카테고리를 최초 1회생성
        let mainCategoryViewControllerObservable = mainViewModel
            .mainCategoryViewModels
            .take(2)
            .observe(on: MainScheduler.instance)
            .map({ mainCategoryViewModels in
                
                // 두번째 emit: 메인카테고리들 전송완료
                if !mainCategoryViewModels.isEmpty { self.dismissIndicator() }
                
                return mainCategoryViewModels.map { viewModel in
                    
                    let viewController = self.mainViewModel.mainCategoryViewControllerFactory.create(viewModel: viewModel)
                    
                    self.insertViewController(viewController)
                    
                    return viewController
                }
            })
        
        // 메인 카테고리 탭바 구성
        mainViewModel
            .mainCategories
            .take(2)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { mainCategories in
                
                if mainCategories.isEmpty { return }
                
                self.mainCategoryTabBarView.setTabBarView(mainCategories: mainCategories)
            })
            .disposed(by: disposeBag)
        
        // 선택된 메인카테고리와 메인카테고리 뷰컨트롤러의 생성이 완료되었을 때 필터링을 시작한다.
        Observable.combineLatest(
            mainCategoryViewControllerObservable,
            mainViewModel.selectedMainCategory
        )
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { (viewControllers, selectedCategory) in
            
            if selectedCategory == .all {
                
                self.showVideoListView()
            } else {
                
                let willShowViewController = viewControllers.first(where: { $0.viewModel.category.categoryId == selectedCategory.categoryId })!
                
                self.view.bringSubviewToFront(willShowViewController.view)
            }
        })
        .disposed(by: disposeBag)

    }
    
    /// 비디오 리스트를 화면에 표시합니다.
    private func showVideoListView() {
        
        view.bringSubviewToFront(videoListViewController.view)
    }

    private func setAutoLayout() {
        
        NSLayoutConstraint.activate([
            
            gestureArea.topAnchor.constraint(equalTo: mainCategoryTabBarView.bottomAnchor),
            gestureArea.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gestureArea.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gestureArea.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
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
        ])
        
        NSLayoutConstraint.activate([
        
            tempSearchView.topAnchor.constraint(equalTo: gestureArea.topAnchor, constant: 20),
            tempSearchView.leadingAnchor.constraint(equalTo: gestureArea.leadingAnchor, constant: 20),
            tempSearchView.trailingAnchor.constraint(equalTo: gestureArea.trailingAnchor, constant: -20),
            tempSearchView.heightAnchor.constraint(equalToConstant: 52),
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
    
    private func insertViewController(_ viewController: UIViewController) {
        
        // willMove를 자동으로 호출한다.
        
        // 현재 뷰컨트롤러의 자식뷰컨트롤러를 지정하는 경우에 호출된다
        self.addChild(viewController)
        
        // ✅ 커스텀 컨테이너 구현시, addChild이후에 반드시 호출해야한다.
        viewController.didMove(toParent: self)
        
        gestureArea.addSubview(viewController.view)
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            viewController.view.topAnchor.constraint(equalTo: tempSearchView.bottomAnchor, constant: 20),
            viewController.view.bottomAnchor.constraint(equalTo: gestureArea.bottomAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: gestureArea.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: gestureArea.trailingAnchor),
        ])
    }
}

extension MainViewController {
    
    @objc
    func onPageTransitionGestureRecognized(_ gesture: UIPanGestureRecognizer) {
        
        
    }
}
