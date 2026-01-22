//
//  HomeViewModel.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//

import Foundation

final class HomeViewModel {

    private let repository = ExpenseRepository.shared

    // MARK: - Expenses
    func getExpenses() -> [Expense] {
        repository.fetchAll()
            .sorted { $0.date > $1.date }
    }

    func deleteExpense(id: UUID) {
        repository.deleteExpense(id: id)
    }

    // MARK: - Monthly Summary

    func currentMonthTotal() -> Double {
        let now = Date()
        let calendar = Calendar.current

        return getExpenses().filter {
            calendar.isDate($0.date, equalTo: now, toGranularity: .month)
        }
        .reduce(0) { $0 + $1.amount }
    }

    func lastMonthTotal() -> Double {
        let calendar = Calendar.current
        guard let lastMonth = calendar.date(byAdding: .month, value: -1, to: Date()) else {
            return 0
        }

        return getExpenses().filter {
            calendar.isDate($0.date, equalTo: lastMonth, toGranularity: .month)
        }
        .reduce(0) { $0 + $1.amount }
    }

    func monthComparisonText() -> String {
        let current = currentMonthTotal()
        let last = lastMonthTotal()

        guard last > 0 else {
            return "No data for last month"
        }

        let diff = ((current - last) / last) * 100
        let arrow = diff >= 0 ? "↑" : "↓"

        return "\(arrow) \(abs(Int(diff)))% from last month"
    }
}
