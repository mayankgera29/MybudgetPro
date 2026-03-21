//
//  BudgetStorageService.swift
//  MyBudget Pro
//

import Foundation

final class BudgetStorageService {

    static let shared = BudgetStorageService()
    private let key = "saved_budgets"

    private init() {}

    func loadBudgets() -> [Budget] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let budgets = try? JSONDecoder().decode([Budget].self, from: data)
        else { return [] }
        return budgets
    }

    func save(_ budgets: [Budget]) {
        guard let data = try? JSONEncoder().encode(budgets) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    func setBudget(for category: CategoryType, limit: Double) {
        var budgets = loadBudgets()
        if limit <= 0 {
            budgets.removeAll { $0.category == category }
        } else if let idx = budgets.firstIndex(where: { $0.category == category }) {
            budgets[idx].monthlyLimit = limit
        } else {
            budgets.append(Budget(category: category, monthlyLimit: limit))
        }
        save(budgets)
    }

    func limit(for category: CategoryType) -> Double? {
        loadBudgets().first(where: { $0.category == category })?.monthlyLimit
    }
}
