//
//  CategoryType.swift
//  MyBudget Pro
//

import UIKit

enum CategoryType: String, Codable, CaseIterable {

    case food
    case groceries
    case transport
    case travel
    case shopping
    case bills
    case subscriptions
    case entertainment
    case dining
    case health
    case fitness
    case education
    case investment
    case personalCare
    case other

    // MARK: - Title
    var title: String {
        switch self {
        case .food:         return "Food"
        case .groceries:    return "Groceries"
        case .transport:    return "Transport"
        case .travel:       return "Travel"
        case .shopping:     return "Shopping"
        case .bills:        return "Bills"
        case .subscriptions: return "Subscriptions"
        case .entertainment: return "Entertainment"
        case .dining:       return "Dining"
        case .health:       return "Health"
        case .fitness:      return "Fitness"
        case .education:    return "Education"
        case .investment:   return "Investment"
        case .personalCare: return "Personal Care"
        case .other:        return "Other"
        }
    }

    // MARK: - Emoji
    var emoji: String {
        switch self {
        case .food:          return "🍔"
        case .groceries:     return "🛒"
        case .transport:     return "🚗"
        case .travel:        return "✈️"
        case .shopping:      return "🛍️"
        case .bills:         return "💡"
        case .subscriptions: return "📱"
        case .entertainment: return "🎬"
        case .dining:        return "🍽️"
        case .health:        return "❤️"
        case .fitness:       return "💪"
        case .education:     return "📚"
        case .investment:    return "📈"
        case .personalCare:  return "🪥"
        case .other:         return "🧾"
        }
    }

    // MARK: - Color
    var color: UIColor {
        switch self {
        case .food:          return UIColor(red: 255/255, green: 149/255, blue: 0/255,   alpha: 1) // orange
        case .groceries:     return UIColor(red: 52/255,  green: 199/255, blue: 89/255,  alpha: 1) // green
        case .transport:     return UIColor(red: 90/255,  green: 200/255, blue: 250/255, alpha: 1) // sky blue
        case .travel:        return UIColor(red: 0/255,   green: 122/255, blue: 255/255, alpha: 1) // blue
        case .shopping:      return UIColor(red: 175/255, green: 82/255,  blue: 222/255, alpha: 1) // purple
        case .bills:         return UIColor(red: 255/255, green: 204/255, blue: 0/255,   alpha: 1) // yellow
        case .subscriptions: return UIColor(red: 255/255, green: 45/255,  blue: 85/255,  alpha: 1) // red
        case .entertainment: return UIColor(red: 255/255, green: 55/255,  blue: 95/255,  alpha: 1) // pink-red
        case .dining:        return UIColor(red: 255/255, green: 179/255, blue: 64/255,  alpha: 1) // amber
        case .health:        return UIColor(red: 255/255, green: 69/255,  blue: 58/255,  alpha: 1) // red
        case .fitness:       return UIColor(red: 48/255,  green: 209/255, blue: 88/255,  alpha: 1) // bright green
        case .education:     return UIColor(red: 100/255, green: 210/255, blue: 255/255, alpha: 1) // light blue
        case .investment:    return UIColor(red: 50/255,  green: 173/255, blue: 230/255, alpha: 1) // teal
        case .personalCare:  return UIColor(red: 255/255, green: 105/255, blue: 180/255, alpha: 1) // hot pink
        case .other:         return UIColor.systemGray
        }
    }

    var backgroundColor: UIColor {
        color.withAlphaComponent(0.15)
    }

    // MARK: - SF Symbol
    var sfSymbol: String {
        switch self {
        case .food:          return "fork.knife"
        case .groceries:     return "cart.fill"
        case .transport:     return "car.fill"
        case .travel:        return "airplane"
        case .shopping:      return "bag.fill"
        case .bills:         return "bolt.fill"
        case .subscriptions: return "play.rectangle.fill"
        case .entertainment: return "film.fill"
        case .dining:        return "cup.and.saucer.fill"
        case .health:        return "heart.fill"
        case .fitness:       return "figure.run"
        case .education:     return "book.fill"
        case .investment:    return "chart.line.uptrend.xyaxis"
        case .personalCare:  return "sparkles"
        case .other:         return "square.grid.2x2.fill"
        }
    }

    // MARK: - Lottie
    var lottieName: String {
        switch self {
        case .food:          return "food"
        case .groceries:     return "shopping"
        case .transport:     return "car"
        case .travel:        return "car"
        case .shopping:      return "shopping"
        case .bills:         return "wallet"
        case .subscriptions: return "entertainment"
        case .entertainment: return "entertainment"
        case .dining:        return "food"
        case .health:        return "health"
        case .fitness:       return "health"
        case .education:     return "wallet"
        case .investment:    return "wallet"
        case .personalCare:  return "health"
        case .other:         return "wallet"
        }
    }
}
