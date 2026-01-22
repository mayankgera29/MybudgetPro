//
//  SplashViewController.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//


import UIKit

final class SplashViewController: UIViewController {

    private let gradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupUI()
        moveNext()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    private func setupUI() {
        let label = UILabel()
        label.text = "MyBudget Pro"
        label.font = .boldSystemFont(ofSize: 34)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func moveNext() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.goToMain()
        }
    }

    // 🔥 CORRECT TRANSITION
    private func goToMain() {

        let tabBar = MainTabBarController()

        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first
        else { return }

        window.rootViewController = tabBar

        UIView.transition(
            with: window,
            duration: 0.4,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }

    private func setupGradient() {
        gradientLayer.colors = [
            UIColor.systemPurple.cgColor,
            UIColor.systemIndigo.cgColor
        ]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}
