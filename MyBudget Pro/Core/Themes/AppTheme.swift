import UIKit

struct AppTheme {

    // MARK: - Brand Accent (Indigo)
    static let primary = UIColor(red: 99/255, green: 102/255, blue: 241/255, alpha: 1)   // indigo-500
    static let primarySoft = UIColor(red: 99/255, green: 102/255, blue: 241/255, alpha: 0.15)

    static let secondary = UIColor(red: 139/255, green: 92/255, blue: 246/255, alpha: 1) // violet-500

    // MARK: - Backgrounds
    static let background = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 10/255,  green: 10/255,  blue: 18/255,  alpha: 1)  // near-black indigo
            : UIColor(red: 250/255, green: 249/255, blue: 246/255, alpha: 1)  // warm cream
    }

    static let surfaceBackground = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 18/255,  green: 18/255,  blue: 30/255,  alpha: 1)  // deep navy
            : UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    }

    static let cardBackground = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 26/255,  green: 26/255,  blue: 46/255,  alpha: 1)  // dark indigo card
            : UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    }

    static let cardOverlay = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.05)
            : UIColor.black.withAlphaComponent(0.02)
    }

    // MARK: - Text
    static let titleText    = UIColor.label
    static let subtitleText = UIColor.secondaryLabel

    static let inverseText = UIColor { trait in
        trait.userInterfaceStyle == .dark ? .black : .white
    }

    // MARK: - Semantic
    static let successColor  = UIColor(red: 52/255,  green: 199/255, blue: 89/255,  alpha: 1)  // system green
    static let warningColor  = UIColor(red: 255/255, green: 159/255, blue: 10/255,  alpha: 1)  // system orange
    static let separatorColor = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.08)
            : UIColor.black.withAlphaComponent(0.06)
    }

    // MARK: - Gradient
    static func gradientColors(for trait: UITraitCollection) -> [CGColor]? {
        if trait.userInterfaceStyle == .dark {
            return [
                UIColor(red: 10/255,  green: 10/255,  blue: 18/255,  alpha: 1).cgColor,
                UIColor(red: 18/255,  green: 14/255,  blue: 38/255,  alpha: 1).cgColor
            ]
        }
        return [
            UIColor(red: 250/255, green: 249/255, blue: 246/255, alpha: 1).cgColor,
            UIColor(red: 243/255, green: 240/255, blue: 255/255, alpha: 1).cgColor  // faint lavender tint
        ]
    }

    // MARK: - Splash gradient
    static func splashGradient(for trait: UITraitCollection) -> [CGColor] {
        if trait.userInterfaceStyle == .dark {
            return [
                UIColor(red: 10/255,  green: 8/255,   blue: 28/255,  alpha: 1).cgColor,
                UIColor(red: 30/255,  green: 20/255,  blue: 70/255,  alpha: 1).cgColor,
                UIColor(red: 10/255,  green: 8/255,   blue: 28/255,  alpha: 1).cgColor
            ]
        }
        return [
            UIColor(red: 238/255, green: 235/255, blue: 255/255, alpha: 1).cgColor,
            UIColor(red: 255/255, green: 248/255, blue: 240/255, alpha: 1).cgColor,
            UIColor(red: 238/255, green: 235/255, blue: 255/255, alpha: 1).cgColor
        ]
    }
}
