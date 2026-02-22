//
//  UIView+Theme.swift.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//

import UIKit

extension UIView {

    func applyAppGradient() {

        // Remove old gradients
        layer.sublayers?
            .filter { $0.name == "AppGradientLayer" }
            .forEach { $0.removeFromSuperlayer() }

        // Ask theme dynamically
        guard let colors = AppTheme.gradientColors(for: traitCollection) else {
            return   // 🔥 dark mode = NO gradient
        }

        let gradient = CAGradientLayer()
        gradient.name = "AppGradientLayer"
        gradient.colors = colors
        gradient.frame = bounds
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)

        layer.insertSublayer(gradient, at: 0)
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
