//
//  SplashViewController.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//


import UIKit

final class SplashViewController: UIViewController {

    private let gradientLayer = CAGradientLayer()
    private let titleLabel = UILabel()
    var onFinish: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackground()
        setupUI()
        moveNext()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        updateGradientColors()
    }

    private func updateGradientColors() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        if isDark {
            gradientLayer.colors = nil // no gradient in dark mode, background color handles it
        } else {
            gradientLayer.colors = [
                UIColor(red: 0.92, green: 0.95, blue: 1.00, alpha: 1).cgColor,
                UIColor(red: 0.85, green: 0.90, blue: 0.98, alpha: 1).cgColor
            ]
        }
    }

    // MARK: - Background (Classy Mix)
    private func setupBackground() {
        view.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 22/255, green: 26/255, blue: 32/255, alpha: 1)
                : UIColor(red: 240/255, green: 248/255, blue: 255/255, alpha: 1)
        }
        gradientLayer.startPoint = CGPoint(x: 0.2, y: 0.0)
        gradientLayer.endPoint   = CGPoint(x: 0.8, y: 1.0)
        updateGradientColors()
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    // MARK: - UI
    private func setupUI() {
        titleLabel.text = "MyBudget Pro"
        titleLabel.font = .boldSystemFont(ofSize: 34)
        titleLabel.textColor = .black
        titleLabel.alpha = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // ✨ Smooth fade-in
        UIView.animate(withDuration: 0.6) {
            self.titleLabel.alpha = 1
        }
    }

    // MARK: - Navigation
    private func moveNext() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.onFinish?()
        }
    }

    private func goToMain() {

        let rootVC: UIViewController =
            UserSession.isUserLoggedIn
            ? MainTabBarController()
            : NameEntryViewController()

        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first
        else { return }

        window.rootViewController = rootVC

        UIView.transition(
            with: window,
            duration: 0.4,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }
}
