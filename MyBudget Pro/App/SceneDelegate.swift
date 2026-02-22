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

        let coordinator = AppCoordinator(window: window)
        self.appCoordinator = coordinator
        coordinator.start()
    }

    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppTheme.background

        appearance.titleTextAttributes = [
            .foregroundColor: AppTheme.titleText
        ]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = AppTheme.titleText
    }
}
