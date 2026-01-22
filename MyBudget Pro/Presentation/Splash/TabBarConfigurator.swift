//
//  TabBarConfigurator.swift
//  MyBudget Pro
//
//  Created by mayank gera on 22/01/26.
//


import UIKit

struct TabBarConfigurator {

    static func apply() {

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        // Dynamic background
        appearance.backgroundColor = AppTheme.background

        // Selected
        appearance.stackedLayoutAppearance.selected.iconColor = AppTheme.primary
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: AppTheme.primary
        ]

        // Normal
        appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
