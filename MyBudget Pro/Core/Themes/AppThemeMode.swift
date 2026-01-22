//
//  AppThemeMode.swift
//  MyBudget Pro
//
//  Created by mayank gera on 22/01/26.
//


import UIKit

enum AppThemeMode: String {
    case light
    case dark
    case system
}

final class ThemeManager {

    static let shared = ThemeManager()
    private init() {}

    private let key = "app_theme_mode"

    var currentMode: AppThemeMode {
        if let saved = UserDefaults.standard.string(forKey: key),
           let mode = AppThemeMode(rawValue: saved) {
            return mode
        }
        return .system
    }

    func applyTheme(_ mode: AppThemeMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: key)

        let style: UIUserInterfaceStyle
        switch mode {
        case .light: style = .light
        case .dark: style = .dark
        case .system: style = .unspecified
        }

        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { $0.overrideUserInterfaceStyle = style }
    }
}
