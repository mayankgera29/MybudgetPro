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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        applyTabBarTheme()
    }

    func setTabs(_ viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
    }

    func applyTabBarTheme() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()

        // Blur background
        let blurEffect = UIBlurEffect(style: traitCollection.userInterfaceStyle == .dark ? .systemUltraThinMaterialDark : .systemUltraThinMaterialLight)
        appearance.backgroundEffect = blurEffect
        appearance.backgroundColor = AppTheme.background.withAlphaComponent(0.6)

        // Top separator line
        appearance.shadowColor = AppTheme.primary.withAlphaComponent(0.12)

        appearance.stackedLayoutAppearance.selected.iconColor = AppTheme.primary
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: AppTheme.primary,
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.tertiaryLabel
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.tertiaryLabel,
            .font: UIFont.systemFont(ofSize: 10, weight: .regular)
        ]

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = AppTheme.primary
        tabBar.unselectedItemTintColor = .tertiaryLabel
    }
}
