//
//  AppTheme.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//


import UIKit

import UIKit

struct AppTheme {

    // MARK: - Brand Colors (DO NOT CHANGE)
    static let primary = UIColor.systemPurple
    static let secondary = UIColor.systemIndigo

    // MARK: - Dynamic Backgrounds (AUTO DARK/LIGHT)
    static let background = UIColor.systemBackground

    static let cardBackground = UIColor { trait in
        trait.userInterfaceStyle == .dark
        ? UIColor.secondarySystemBackground
        : UIColor.white
    }

    static let cardOverlay = UIColor { trait in
        trait.userInterfaceStyle == .dark
        ? UIColor.white.withAlphaComponent(0.08)
        : UIColor.black.withAlphaComponent(0.05)
    }

    // MARK: - Text Colors (AUTO ADJUST)
    static let titleText = UIColor.label
    static let subtitleText = UIColor.secondaryLabel

    static let inverseText = UIColor { trait in
        trait.userInterfaceStyle == .dark ? .black : .white
    }

    // MARK: - Gradient (AUTO DARK/LIGHT)
    static let gradientColors: [CGColor] = {
        let isDark = UITraitCollection.current.userInterfaceStyle == .dark

        if isDark {
            return [
                UIColor(red: 25/255, green: 25/255, blue: 35/255, alpha: 1).cgColor,
                UIColor(red: 55/255, green: 45/255, blue: 90/255, alpha: 1).cgColor
            ]
        } else {
            return [
                UIColor.systemPurple.cgColor,
                UIColor.systemIndigo.cgColor
            ]
        }
    }()
}
