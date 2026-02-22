//
//  MainTabBarCoordinator.swift
//  MyBudget Pro
//
//  Created by Mayank Gera on 01/02/26.
//


import UIKit

final class MainTabBarCoordinator {

    private let window: UIWindow
    private let tabBarController = MainTabBarController()

    private let homeCoordinator: HomeCoordinator
    private let categoriesCoordinator: CategoriesCoordinator
    private let reportsCoordinator: ReportsCoordinator

    init(window: UIWindow) {
        self.window = window

        let homeNav = UINavigationController()
        let categoriesNav = UINavigationController()
        let reportsNav = UINavigationController()

        self.homeCoordinator = HomeCoordinator(navigationController: homeNav)
        self.categoriesCoordinator = CategoriesCoordinator(navigationController: categoriesNav)
        self.reportsCoordinator = ReportsCoordinator(navigationController: reportsNav)

        homeNav.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            tag: 0
        )

        categoriesNav.tabBarItem = UITabBarItem(
            title: "Categories",
            image: UIImage(systemName: "square.grid.2x2"),
            tag: 1
        )

        reportsNav.tabBarItem = UITabBarItem(
            title: "Reports",
            image: UIImage(systemName: "chart.pie"),
            tag: 2
        )

        tabBarController.setTabs([
            homeNav,
            categoriesNav,
            reportsNav
        ])
    }

    func start() {
        homeCoordinator.start()
        categoriesCoordinator.start()
        reportsCoordinator.start()

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
