import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBarSeparator()
        
        let trackerVC = TrackerViewController()
        trackerVC.view.backgroundColor = .white
        trackerVC.tabBarItem = UITabBarItem(title: NSLocalizedString("tab.trackers", comment: "trackers tab titile"), image: UIImage.trackersTabbarIcon , tag: 0)
        
        let statisticVC = StatistickViewController()
        statisticVC.view.backgroundColor = .white
        statisticVC.tabBarItem = UITabBarItem(title: NSLocalizedString("tab.statistics", comment: "statistic tab title"), image: UIImage.statisticTabbarIcon, tag: 1)
        
        viewControllers = [
            UINavigationController(rootViewController: trackerVC),
            UINavigationController(rootViewController: statisticVC)]
    }
    
    private func setupTabBarSeparator() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = .white
        appearance.shadowColor = UIColor.systemGray4
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}
