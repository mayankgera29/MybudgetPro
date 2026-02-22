//
//  CategoriesViewModel.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//

import Foundation

final class CategoriesViewModel {

    private let repository = ExpenseRepository.shared
    private var currentFilter: DateFilter = .all

    func setFilter(_ filter: DateFilter) {
        currentFilter = filter
    }

    // ✅ THIS IS WHAT YOUR VC EXPECTS
    func getCategoryTotals() -> [(CategoryType, Double)] {

        let expenses = applyFilter(repository.fetchAll())
        let grouped = Dictionary(grouping: expenses, by: { $0.category })

        return grouped.map { category, items in
            (category, items.reduce(0) { $0 + $1.amount })
        }
        .sorted { $0.1 > $1.1 }
    }

    func maxCategoryTotal() -> Double {
        getCategoryTotals().map { $0.1 }.max() ?? 1
    }

    private func applyFilter(_ expenses: [Expense]) -> [Expense] {
        let cal = Calendar.current
        let now = Date()

        switch currentFilter {
        case .all:
            return expenses
        case .today:
            return expenses.filter { cal.isDateInToday($0.date) }
        case .thisMonth:
            return expenses.filter {
                cal.isDate($0.date, equalTo: now, toGranularity: .month)
            }
        case .custom(let from, let to):
            return expenses.filter { $0.date >= from && $0.date <= to }
        }
    }
}
