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
    }

    func setTabs(_ viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
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
