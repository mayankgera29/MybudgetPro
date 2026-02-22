//
//  HomeViewModel.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//

import Foundation

final class HomeViewModel {

    // MARK: - Dependencies
    private let repository: ExpenseRepositoryProtocol

    // MARK: - Init
    init(repository: ExpenseRepositoryProtocol = ExpenseRepository.shared) {
        self.repository = repository
    }

    // MARK: - Public API (USED BY VC)

    func makeViewState() -> HomeViewState {
        let expenses = fetchSortedExpenses()
        let comparisonText = makeMonthComparisonText(from: expenses)

        return HomeViewState(
            expenses: expenses,
            isEmpty: expenses.isEmpty,
            monthComparisonText: comparisonText
        )
    }

    func deleteExpense(id: UUID) {
        repository.deleteExpense(id: id)
    }

    // MARK: - Private Helpers

    private func fetchSortedExpenses() -> [Expense] {
        repository.fetchAll()
            .sorted { $0.date > $1.date }
    }

    private func makeMonthComparisonText(from expenses: [Expense]) -> String {
        let calendar = Calendar.current
        let now = Date()

        let currentMonthTotal = expenses
            .filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }

        guard
            let lastMonthDate = calendar.date(byAdding: .month, value: -1, to: now)
        else {
            return "No data"
        }

        let lastMonthTotal = expenses
            .filter { calendar.isDate($0.date, equalTo: lastMonthDate, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }

        guard lastMonthTotal > 0 else {
            return "No data for last month"
        }

        let diff = ((currentMonthTotal - lastMonthTotal) / lastMonthTotal) * 100
        let arrow = diff >= 0 ? "↑" : "↓"

        return "\(arrow) \(abs(Int(diff)))% from last month"
    }
}
