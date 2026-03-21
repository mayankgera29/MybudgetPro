//
//  UIView+Theme.swift
//  MyBudget Pro
//

import UIKit

extension UIView {

    /// Applies or resizes the app gradient layer. Safe to call from viewDidLayoutSubviews.
    func applyAppGradient() {
        if let existing = layer.sublayers?.first(where: { $0.name == "AppGradientLayer" }) as? CAGradientLayer {
            existing.frame = bounds
            existing.colors = AppTheme.gradientColors(for: traitCollection)
            return
        }

        guard let colors = AppTheme.gradientColors(for: traitCollection) else { return }

        let gradient = CAGradientLayer()
        gradient.name = "AppGradientLayer"
        gradient.colors = colors
        gradient.frame = bounds
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)

        // Insert above OrbBackground subview layer but below everything else
        layer.insertSublayer(gradient, at: 0)
    }

    /// Call on traitCollectionDidChange to refresh gradient colors.
    func refreshAppGradient() {
        // Remove all stale gradient layers first
        layer.sublayers?
            .filter { $0.name == "AppGradientLayer" }
            .forEach { $0.removeFromSuperlayer() }
        applyAppGradient()
    }

    func applyCardStyle() {
        backgroundColor = AppTheme.cardBackground
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 4)
    }
}
