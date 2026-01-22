//
//  MainTabBarController.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//


import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        applyTabBarTheme()
        setupTabs()
    }

    private func setupTabs() {

        let home = UINavigationController(rootViewController: HomeViewController())
        home.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)

        let categories = UINavigationController(rootViewController: CategoriesViewController())
        categories.tabBarItem = UITabBarItem(title: "Categories", image: UIImage(systemName: "square.grid.2x2"), tag: 1)

        let reports = UINavigationController(rootViewController: ReportsViewController())
        reports.tabBarItem = UITabBarItem(title: "Reports", image: UIImage(systemName: "chart.pie"), tag: 2)

        viewControllers = [home, categories, reports]
    }

    func applyTabBarTheme() {

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppTheme.background

        appearance.stackedLayoutAppearance.selected.iconColor = AppTheme.primary
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: AppTheme.primary
        ]

        appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray
        ]

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = AppTheme.primary
        tabBar.unselectedItemTintColor = .systemGray
    }
}
