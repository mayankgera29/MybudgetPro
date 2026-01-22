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

    // MARK: - Title
    var title: String {
        rawValue.capitalized
    }

    // MARK: - Emoji (USED IN CATEGORIES)
    var emoji: String {
        switch self {
        case .food: return "🍔"
        case .transport: return "🚗"
        case .shopping: return "🛍️"
        case .bills: return "💡"
        case .entertainment: return "🎬"
        case .health: return "❤️"
        }
    }

    // MARK: - Primary Color
    var color: UIColor {
        switch self {
        case .food: return .systemOrange
        case .transport: return .systemBlue
        case .shopping: return .systemPink
        case .bills: return .systemPurple
        case .entertainment: return .systemRed
        case .health: return .systemGreen
        }
    }

    // MARK: - Soft Background (USED IN CATEGORY TILES)
    var backgroundColor: UIColor {
        color.withAlphaComponent(0.15)
    }

    // MARK: - LOTTIE (USED ONLY IN HOME)
    var lottieName: String {
        switch self {
        case .food: return "food"
        case .transport: return "car"
        case .shopping: return "shopping"
        case .bills: return "wallet"
        case .entertainment: return "entertainment"
        case .health: return "health"
        }
    }

}
