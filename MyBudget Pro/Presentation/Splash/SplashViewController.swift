//
//  SplashViewController.swift
//  MyBudget Pro
//

import UIKit

final class SplashViewController: UIViewController {

    var onFinish: (() -> Void)?

    private let gradientLayer = CAGradientLayer()

    // Logo
    private let logoContainer  = UIView()
    private let iconCircle     = UIView()
    private let iconImageView  = UIImageView()
    private let wordmarkLabel  = UILabel()
    private let taglineLabel   = UILabel()

    // Loader
    private let loaderStack    = UIStackView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupOrbs()
        setupLogo()
        setupTagline()
        setupLoader()
        animateIn()
        scheduleFinish()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        gradientLayer.colors = AppTheme.splashGradient(for: traitCollection)
    }

    // MARK: - Background
    private func setupBackground() {
        view.backgroundColor = AppTheme.background
        gradientLayer.colors = AppTheme.splashGradient(for: traitCollection)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupOrbs() {
        // Two subtle ambient orbs for depth
        let orb1 = makeOrb(color: AppTheme.primary, size: 280, alpha: 0.10)
        let orb2 = makeOrb(color: AppTheme.secondary, size: 200, alpha: 0.08)
        view.addSubview(orb1)
        view.addSubview(orb2)
        NSLayoutConstraint.activate([
            orb1.centerXAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            orb1.centerYAnchor.constraint(equalTo: view.topAnchor, constant: 120),
            orb2.centerXAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            orb2.centerYAnchor.constraint(equalTo: view.bottomAnchor, constant: -160)
        ])
    }

    private func makeOrb(color: UIColor, size: CGFloat, alpha: CGFloat) -> UIView {
        let v = UIView()
        v.backgroundColor = color.withAlphaComponent(alpha)
        v.layer.cornerRadius = size / 2
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalToConstant: size).isActive = true
        v.heightAnchor.constraint(equalToConstant: size).isActive = true
        return v
    }

    // MARK: - Logo
    private func setupLogo() {
        // Outer glow ring
        let glowRing = UIView()
        glowRing.backgroundColor = AppTheme.primary.withAlphaComponent(0.10)
        glowRing.layer.cornerRadius = 52
        glowRing.layer.borderWidth = 1
        glowRing.layer.borderColor = AppTheme.primary.withAlphaComponent(0.25).cgColor
        glowRing.translatesAutoresizingMaskIntoConstraints = false

        // Inner filled circle
        iconCircle.backgroundColor = AppTheme.primary
        iconCircle.layer.cornerRadius = 36
        iconCircle.layer.shadowColor = AppTheme.primary.cgColor
        iconCircle.layer.shadowOpacity = 0.45
        iconCircle.layer.shadowRadius = 18
        iconCircle.layer.shadowOffset = .zero
        iconCircle.translatesAutoresizingMaskIntoConstraints = false

        // SF Symbol icon
        let cfg = UIImage.SymbolConfiguration(pointSize: 28, weight: .semibold)
        iconImageView.image = UIImage(systemName: "chart.line.uptrend.xyaxis", withConfiguration: cfg)
        iconImageView.tintColor = .white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        // Wordmark
        wordmarkLabel.text = "MyBudget Pro"
        wordmarkLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        wordmarkLabel.textColor = .label
        wordmarkLabel.textAlignment = .center
        wordmarkLabel.translatesAutoresizingMaskIntoConstraints = false

        logoContainer.translatesAutoresizingMaskIntoConstraints = false
        logoContainer.addSubview(glowRing)
        logoContainer.addSubview(iconCircle)
        logoContainer.addSubview(iconImageView)
        logoContainer.addSubview(wordmarkLabel)
        view.addSubview(logoContainer)

        NSLayoutConstraint.activate([
            logoContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -24),

            glowRing.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
            glowRing.topAnchor.constraint(equalTo: logoContainer.topAnchor),
            glowRing.widthAnchor.constraint(equalToConstant: 104),
            glowRing.heightAnchor.constraint(equalToConstant: 104),

            iconCircle.centerXAnchor.constraint(equalTo: glowRing.centerXAnchor),
            iconCircle.centerYAnchor.constraint(equalTo: glowRing.centerYAnchor),
            iconCircle.widthAnchor.constraint(equalToConstant: 72),
            iconCircle.heightAnchor.constraint(equalToConstant: 72),

            iconImageView.centerXAnchor.constraint(equalTo: iconCircle.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconCircle.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 34),
            iconImageView.heightAnchor.constraint(equalToConstant: 34),

            wordmarkLabel.topAnchor.constraint(equalTo: glowRing.bottomAnchor, constant: 22),
            wordmarkLabel.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
            wordmarkLabel.bottomAnchor.constraint(equalTo: logoContainer.bottomAnchor)
        ])
    }

    // MARK: - Tagline
    private func setupTagline() {
        taglineLabel.text = "Track smarter. Spend better."
        taglineLabel.font = .systemFont(ofSize: 14, weight: .medium)
        taglineLabel.textColor = .secondaryLabel
        taglineLabel.textAlignment = .center
        taglineLabel.alpha = 0
        taglineLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(taglineLabel)

        NSLayoutConstraint.activate([
            taglineLabel.topAnchor.constraint(equalTo: logoContainer.bottomAnchor, constant: 10),
            taglineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: - Loader
    private func setupLoader() {
        loaderStack.axis = .horizontal
        loaderStack.spacing = 6
        loaderStack.alignment = .center
        loaderStack.alpha = 0
        loaderStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loaderStack)

        for _ in 0..<3 {
            let dot = UIView()
            dot.backgroundColor = AppTheme.primary.withAlphaComponent(0.4)
            dot.layer.cornerRadius = 3.5
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.widthAnchor.constraint(equalToConstant: 7).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 7).isActive = true
            loaderStack.addArrangedSubview(dot)
        }

        NSLayoutConstraint.activate([
            loaderStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loaderStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -52)
        ])
    }

    // MARK: - Animations
    private func animateIn() {
        logoContainer.alpha = 0
        logoContainer.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        iconCircle.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)

        UIView.animate(withDuration: 0.8, delay: 0.1, usingSpringWithDamping: 0.65, initialSpringVelocity: 0.4) {
            self.logoContainer.alpha = 1
            self.logoContainer.transform = .identity
            self.iconCircle.transform = .identity
        }

        UIView.animate(withDuration: 0.5, delay: 0.55) {
            self.taglineLabel.alpha = 1
            self.loaderStack.alpha = 1
        }

        animateDots()
    }

    private func animateDots() {
        loaderStack.arrangedSubviews.enumerated().forEach { i, dot in
            UIView.animate(
                withDuration: 0.5,
                delay: Double(i) * 0.18,
                options: [.repeat, .autoreverse, .curveEaseInOut]
            ) {
                dot.transform = CGAffineTransform(scaleX: 1.6, y: 1.6)
                dot.backgroundColor = AppTheme.primary
            }
        }
    }

    // MARK: - Navigation
    private func scheduleFinish() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) { [weak self] in
            UIView.animate(withDuration: 0.35) {
                self?.view.alpha = 0
            } completion: { _ in
                self?.onFinish?()
            }
        }
    }
}
