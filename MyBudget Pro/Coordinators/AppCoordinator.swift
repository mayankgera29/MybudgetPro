//
//  AppCoordinator.swift
//  MyBudget Pro
//
//  Created by Mayank Gera on 01/02/26.
//


import UIKit

final class AppCoordinator {

    private let window: UIWindow
    private var mainTabCoordinator: MainTabBarCoordinator?

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        showSplash()
    }

    private func showSplash() {
        let splashVC = SplashViewController()
        splashVC.onFinish = { [weak self] in
            self?.decideInitialFlow()
        }

        window.rootViewController = splashVC
        window.makeKeyAndVisible()
    }

    private func decideInitialFlow() {
        if UserSession.isUserLoggedIn {
            showMainTab()
        } else {
            showNameEntry()
        }
    }

    private func showNameEntry() {
        let nameVC = NameEntryViewController()
        nameVC.onFinish = { [weak self] in
            self?.showMainTab()
        }

        transition(to: nameVC)
    }

    private func showMainTab() {
        let tabCoordinator = MainTabBarCoordinator(window: window)
        tabCoordinator.start()
    }

    private func transition(to vc: UIViewController) {
        UIView.transition(
            with: window,
            duration: 0.35,
            options: .transitionCrossDissolve,
            animations: {
                self.window.rootViewController = vc
            }
        )
    }
}
