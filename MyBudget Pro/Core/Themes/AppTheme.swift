import UIKit

struct AppTheme {

    // MARK: - Brand Colors (LIGHT BLUISH PASTEL)
    static let primary = UIColor(
        red: 175/255,
        green: 210/255,
        blue: 240/255,
        alpha: 1
    )

    static let secondary = UIColor(
        red: 200/255,
        green: 225/255,
        blue: 250/255,
        alpha: 1
    )

    // MARK: - Dynamic Backgrounds
    static let background = UIColor { trait in
        trait.userInterfaceStyle == .dark
        ? UIColor(
            red: 22/255,
            green: 26/255,
            blue: 32/255,
            alpha: 1
          )   // 🌙 soft dark (NOT pure black)
        : UIColor(
            red: 240/255,
            green: 248/255,
            blue: 255/255,
            alpha: 1
          )   // ☀️ light blue pastel
    }

    static let cardBackground = UIColor { trait in
        trait.userInterfaceStyle == .dark
        ? UIColor(red: 34/255, green: 38/255, blue: 46/255, alpha: 1)
        : UIColor.white
    }

    static let cardOverlay = UIColor { trait in
        trait.userInterfaceStyle == .dark
        ? UIColor.white.withAlphaComponent(0.08)
        : UIColor.black.withAlphaComponent(0.015)
    }

    // MARK: - Text
    static let titleText = UIColor.label
    static let subtitleText = UIColor.secondaryLabel

    static let inverseText = UIColor { trait in
        trait.userInterfaceStyle == .dark ? .black : .white
    }

    // MARK: - Gradient (VERY LIGHT BLUE)
    static func gradientColors(for trait: UITraitCollection) -> [CGColor]? {

        // ❌ No gradient in dark mode
        if trait.userInterfaceStyle == .dark {
            return nil
        }

        // ✅ Light mode only
        return [
            UIColor(red: 240/255, green: 248/255, blue: 255/255, alpha: 1).cgColor,
            UIColor(red: 225/255, green: 240/255, blue: 255/255, alpha: 1).cgColor
        ]
    }
}
