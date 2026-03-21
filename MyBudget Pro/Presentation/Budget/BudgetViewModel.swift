//
//  BudgetViewModel.swift
//  MyBudget Pro
//

import Foundation

struct BudgetRow {
    let category: CategoryType
    let spent: Double
    let limit: Double
    var ratio: Double { limit > 0 ? min(spent / limit, 1.0) : 0 }
    var isOverBudget: Bool { limit > 0 && spent > limit }
    var remaining: Double { max(limit - spent, 0) }
}

final class BudgetViewModel {

    private let repository: ExpenseRepositoryProtocol
    private let storage = BudgetStorageService.shared
    private let exchangeService = ExchangeRateService()

    // Live exchange rate (INR → USD)
    private(set) var usdRate: Double?
    private(set) var isLoadingRate = false
    private(set) var rateError: String?

    init(repository: ExpenseRepositoryProtocol = ExpenseRepository.shared) {
        self.repository = repository
    }

    // MARK: - Budget rows for current month
    func budgetRows() -> [BudgetRow] {
        let calendar = Calendar.current
        let now = Date()
        let expenses = repository.fetchAll().filter {
            calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }

        let spentByCategory = Dictionary(grouping: expenses, by: { $0.category })
            .mapValues { $0.reduce(0) { $0 + $1.amount } }

        return CategoryType.allCases.compactMap { category in
            guard let limit = storage.limit(for: category) else { return nil }
            let spent = spentByCategory[category] ?? 0
            return BudgetRow(category: category, spent: spent, limit: limit)
        }
    }

    // MARK: - Total this month
    func totalSpentThisMonth() -> Double {
        let calendar = Calendar.current
        let now = Date()
        return repository.fetchAll()
            .filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }

    func totalBudget() -> Double {
        BudgetStorageService.shared.loadBudgets().reduce(0) { $0 + $1.monthlyLimit }
    }

    // MARK: - Set budget
    func setBudget(for category: CategoryType, limit: Double) {
        storage.setBudget(for: category, limit: limit)
    }

    func currentLimit(for category: CategoryType) -> Double {
        storage.limit(for: category) ?? 0
    }

    // MARK: - Exchange rate
    func fetchExchangeRate() async {
        isLoadingRate = true
        rateError = nil
        do {
            usdRate = try await exchangeService.fetchINRtoUSD()
        } catch {
            // Fallback to bundled rate
            usdRate = 0.012
            rateError = "Using cached rate"
        }
        isLoadingRate = false
    }

    func inrToUSD(_ inr: Double) -> String {
        guard let rate = usdRate else { return "—" }
        let usd = inr * rate
        return String(format: "$%.2f", usd)
    }
}
