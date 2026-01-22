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

    // MARK: - Set Filter
    func setFilter(_ filter: DateFilter) {
        currentFilter = filter
    }

    // MARK: - Category Totals (ALWAYS FRESH DATA)
    func getCategoryTotals() -> [(CategoryType, Double)] {

        let allExpenses = repository.fetchAll()

        // ✅ Apply filter on fresh data
        let filteredExpenses = applyFilter(allExpenses)

        let grouped = Dictionary(grouping: filteredExpenses, by: { $0.category })

        return grouped.map { category, expenses in
            let total = expenses.reduce(0) { $0 + $1.amount }
            return (category, total)
        }
        .sorted { $0.0.title < $1.0.title }
    }

    // MARK: - Date Filter Logic
    private func applyFilter(_ expenses: [Expense]) -> [Expense] {

        let calendar = Calendar.current

        switch currentFilter {

        case .all:
            return expenses

        case .today:
            return expenses.filter {
                calendar.isDateInToday($0.date)
            }

        case .thisMonth:
            return expenses.filter {
                calendar.isDate($0.date, equalTo: Date(), toGranularity: .month)
            }

        case .custom(let from, let to):
            return expenses.filter {
                $0.date >= from && $0.date <= to
            }
        }
    }
}
