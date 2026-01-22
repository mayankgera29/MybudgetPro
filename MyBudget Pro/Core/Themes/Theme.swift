//
//  Theme.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//


import UIKit

enum Theme {

    // MARK: - Gradients
    static let gradientColors: [CGColor] = [
        UIColor(red: 123/255, green: 97/255, blue: 255/255, alpha: 1).cgColor,
        UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1).cgColor
    ]

    // MARK: - Backgrounds
    static let screenBackground = UIColor.clear
    static let cardBackground = UIColor.white
    static let cardOverlay = UIColor.white.withAlphaComponent(0.15)

    // MARK: - Primary Colors
    static let primary = UIColor.systemPurple
    static let secondary = UIColor.systemIndigo

    // MARK: - Text Colors
    static let titleText = UIColor.white
    static let subtitleText = UIColor.white.withAlphaComponent(0.75)
    static let darkText = UIColor.black

    // MARK: - Buttons
    static let floatingButton = UIColor.systemPurple
}
