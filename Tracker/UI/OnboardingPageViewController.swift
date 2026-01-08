import UIKit

final class OnboardingPageViewController: UIPageViewController {
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            backgroundImage: UIImage(named: "background_1"),
            title: "Отслеживайте только \n то, что хотите"
            
        ),
        OnboardingPage(
            backgroundImage: UIImage(named: "background_2"),
            title: "Даже если это \n не литры воды и йога"
        )
    ]
    
    private var pageControllers: [OnboardingContentViewController] = []
    
    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPageIndicatorTintColor = .black
        pc.pageIndicatorTintColor = .lightGray
        pc.translatesAutoresizingMaskIntoConstraints = false
        return pc
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        pageControllers = pages.map { OnboardingContentViewController(page: $0) }
        
        if let firstVC = pageControllers.first {
            setViewControllers([firstVC], direction: .forward, animated: true)
        }
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(pageControl)
        view.addSubview(actionButton)
        
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -20),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    @objc private func actionButtonTapped() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = TabBarController()
            UIView.transition(with: window,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: nil)
        }
    }
}

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let contentVC = viewController as? OnboardingContentViewController,
              let index = pageControllers.firstIndex(of: contentVC) else {
            return nil
        }
        let prevIndex = index - 1
        return prevIndex >= 0 ? pageControllers[prevIndex] : nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let contentVC = viewController as? OnboardingContentViewController,
              let index = pageControllers.firstIndex(of: contentVC) else {
            return nil
        }
        let nextIndex = index + 1
        return nextIndex < pageControllers.count ? pageControllers[nextIndex] : nil
    }
}

extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let currentVC = viewControllers?.first as? OnboardingContentViewController,
              let index = pageControllers.firstIndex(of: currentVC) else { return }
        pageControl.currentPage = index
    }
}
