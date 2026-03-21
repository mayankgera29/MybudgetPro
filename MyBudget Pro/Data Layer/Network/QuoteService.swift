//
//  QuoteService.swift
//  MyBudget Pro
//

import Foundation

struct DailyQuote {
    let text: String
    let author: String
}

final class QuoteService {

    static let shared = QuoteService()
    private init() {}

    private let cacheKey = "cached_daily_quote"
    private let cacheDateKey = "cached_daily_quote_date"

    // Returns cached quote if already fetched today, otherwise hits the API
    func fetchTodayQuote() async -> DailyQuote? {
        if let cached = loadCachedQuote() { return cached }

        guard let url = URL(string: "https://zenquotes.io/api/today") else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([ZenQuoteResponse].self, from: data)
            guard let first = decoded.first else { return nil }
            let quote = DailyQuote(text: first.q, author: first.a)
            cacheQuote(quote)
            return quote
        } catch {
            return fallbackQuote()
        }
    }

    // MARK: - Cache (one per day)
    private func loadCachedQuote() -> DailyQuote? {
        let defaults = UserDefaults.standard
        guard
            let savedDate = defaults.object(forKey: cacheDateKey) as? Date,
            Calendar.current.isDateInToday(savedDate),
            let text = defaults.string(forKey: cacheKey + "_text"),
            let author = defaults.string(forKey: cacheKey + "_author")
        else { return nil }
        return DailyQuote(text: text, author: author)
    }

    private func cacheQuote(_ quote: DailyQuote) {
        let defaults = UserDefaults.standard
        defaults.set(quote.text, forKey: cacheKey + "_text")
        defaults.set(quote.author, forKey: cacheKey + "_author")
        defaults.set(Date(), forKey: cacheDateKey)
    }

    // Shown if API fails and no cache exists
    private func fallbackQuote() -> DailyQuote {
        DailyQuote(
            text: "A budget is telling your money where to go instead of wondering where it went.",
            author: "Dave Ramsey"
        )
    }
}

// MARK: - Decodable
private struct ZenQuoteResponse: Decodable {
    let q: String
    let a: String
}
