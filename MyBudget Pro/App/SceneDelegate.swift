//
//  SceneDelegate.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        configureNavigationBar()

        // Apply saved theme preference before showing any UI
        let savedMode = ThemeManager.shared.currentMode
        let style: UIUserInterfaceStyle
        switch savedMode {
        case .light: style = .light
        case .dark:  style = .dark
        case .system: style = .unspecified
        }
        window.overrideUserInterfaceStyle = style

        let coordinator = AppCoordinator(window: window)
        self.appCoordinator = coordinator
        coordinator.start()
    }

    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        // Use dynamic UIColor so it auto-updates on trait changes
        appearance.backgroundColor = AppTheme.background
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.label
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = AppTheme.primary
    }
}
