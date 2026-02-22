//
//  CategoryType.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//
import UIKit

enum CategoryType: String, Codable, CaseIterable {

    case food
    case transport
    case shopping
    case bills
    case entertainment
    case health
    case other

    // MARK: - Title
    var title: String {
        rawValue.capitalized
    }

    // MARK: - Emoji
    var emoji: String {
        switch self {
        case .food: return "🍔"
        case .transport: return "🚗"
        case .shopping: return "🛍️"
        case .bills: return "💡"
        case .entertainment: return "🎬"
        case .health: return "❤️"
        case .other: return "🧾"   // ✅ CLEAN & MEANINGFUL
        }
    }

    // MARK: - Primary Color
    var color: UIColor {
        switch self {
        case .food:
            return UIColor(red: 235/255, green: 170/255, blue: 145/255, alpha: 1)
        case .transport:
            return UIColor(red: 150/255, green: 200/255, blue: 180/255, alpha: 1)
        case .shopping:
            return UIColor(red: 180/255, green: 165/255, blue: 215/255, alpha: 1)
        case .bills:
            return UIColor(red: 165/255, green: 190/255, blue: 225/255, alpha: 1)
        case .entertainment:
            return UIColor(red: 215/255, green: 155/255, blue: 175/255, alpha: 1)
        case .health:
            return UIColor(red: 155/255, green: 200/255, blue: 155/255, alpha: 1)
        case .other:
            return UIColor.systemGray   // ✅ Neutral
        }
    }

    // MARK: - Background Color
    var backgroundColor: UIColor {
        color.withAlphaComponent(0.15)
    }

    // MARK: - Lottie (USED IN HOME)
    var lottieName: String {
        switch self {
        case .food: return "food"
        case .transport: return "car"
        case .shopping: return "shopping"
        case .bills: return "wallet"
        case .entertainment: return "entertainment"
        case .health: return "health"
        case .other: return "wallet"   // ✅ SAFE FALLBACK
        }
    }
}
