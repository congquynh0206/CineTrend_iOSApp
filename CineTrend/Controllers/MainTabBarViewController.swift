//
//  MainTabBarViewController.swift
//  CineTrend
//
//  Created by Trangptt on 2/1/26.
//

import UIKit

class MainTabBarViewController : UITabBarController{
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        let vc1 = UINavigationController(rootViewController: HomeViewController())
        let vc2 = UINavigationController(rootViewController: FavoritesViewController())
        
        vc1.tabBarItem.image = UIImage(systemName: "house")
        vc1.tabBarItem.title = "Home"
        
        vc2.tabBarItem.image = UIImage(systemName: "heart")
        vc2.tabBarItem.title = "Favorites"
        
        tabBar.tintColor = .label
        setupAppearance()
        
        setViewControllers( [vc1,vc2] , animated: true)
    }
    
    private func setupAppearance() {
            // Tabbar
            let tabAppearance = UITabBarAppearance()
            tabAppearance.configureWithTransparentBackground()
            tabAppearance.backgroundColor = .systemBackground
            
            // Áp dụng cho cả lúc cuộn và lúc đứng yên
            UITabBar.appearance().standardAppearance = tabAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
            UITabBar.appearance().tintColor = .label
            
            // Navigation bar
            let navAppearance = UINavigationBarAppearance()
            navAppearance.configureWithTransparentBackground()
            navAppearance.backgroundColor = .systemBackground
            
            // Tiêu đề
            navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
            navAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
            
            // Áp dụng toàn app
            UINavigationBar.appearance().standardAppearance = navAppearance
            UINavigationBar.appearance().compactAppearance = navAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        }
}
