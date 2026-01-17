import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBarAppearance()
        
        let trackerVC = TrackerViewController()
        trackerVC.view.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? Colors.WhiteNight : .systemBackground }
        
        trackerVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tab.trackers", comment: "trackers tab title"),
            image: UIImage.trackersTabbarIcon,
            tag: 0
        )
        
        let statisticVC = StatistickViewController()
        statisticVC.view.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? Colors.WhiteNight : .systemBackground }
        
        statisticVC.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tab.statistics", comment: "statistics tab title"),
            image: UIImage.statisticTabbarIcon,
            tag: 1
        )
        
        viewControllers = [
            UINavigationController(rootViewController: trackerVC),
            UINavigationController(rootViewController: statisticVC)
        ]
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? Colors.WhiteNight : .systemBackground
        }
        
        appearance.shadowColor = .separator
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = nil
        tabBar.unselectedItemTintColor = nil
    }
}
