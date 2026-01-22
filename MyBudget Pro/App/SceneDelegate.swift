//
//  SceneDelegate.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {

        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)

        configureNavigationBar()

        // ✅ Start from Splash
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
        self.window = window
    }

    // MARK: - Navigation Bar
    private func configureNavigationBar() {

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppTheme.background

        appearance.titleTextAttributes = [
            .foregroundColor: AppTheme.titleText
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: AppTheme.titleText
        ]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = AppTheme.titleText
    }
}
