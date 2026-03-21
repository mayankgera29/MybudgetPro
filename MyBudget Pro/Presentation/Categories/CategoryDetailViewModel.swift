//
//  CategoryDetailViewModel.swift
//  MyBudget Pro
//

import Foundation

final class CategoryDetailViewModel {

    // MARK: - Dependencies
    private let repository: ExpenseRepositoryProtocol
    let category: CategoryType

    // MARK: - State
    private(set) var items: [Expense] = []
    private var currentFilter: DateFilter = .all

    // MARK: - Init
    init(category: CategoryType, repository: ExpenseRepositoryProtocol = ExpenseRepository.shared) {
        self.category = category
        self.repository = repository
    }

    // MARK: - Public API
    func applyFilter(_ filter: DateFilter) {
        currentFilter = filter
        loadData()
    }

    func loadData() {
        let all = repository.fetchAll().filter { $0.category == category }
        items = filtered(all)
    }

    // MARK: - Private
    private func filtered(_ expenses: [Expense]) -> [Expense] {
        let cal = Calendar.current
        switch currentFilter {
        case .all:
            return expenses
        case .today:
            return expenses.filter { cal.isDateInToday($0.date) }
        case .thisMonth:
            return expenses.filter { cal.isDate($0.date, equalTo: Date(), toGranularity: .month) }
        case .custom(let from, let to):
            return expenses.filter { $0.date >= from && $0.date <= to }
        }
    }
}
