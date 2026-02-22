//
//  ExpenseRepositoryProtocol.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//

import Foundation

protocol ExpenseRepositoryProtocol {
    func fetchAll() -> [Expense]
    func addExpense(_ expense: Expense)
    func deleteExpense(id: UUID)
}

final class ExpenseRepository: ExpenseRepositoryProtocol {

    static let shared = ExpenseRepository()
    private var expenses: [Expense]

    private init() {
        expenses = FileStorageService.shared.load() ?? []
    }

    func fetchAll() -> [Expense] {
        expenses
    }

    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        FileStorageService.shared.save(expenses)

        NotificationCenter.default.post(name: .expenseUpdated, object: nil)
    }

    func deleteExpense(id: UUID) {
        expenses.removeAll { $0.id == id }
        FileStorageService.shared.save(expenses)

        NotificationCenter.default.post(name: .expenseUpdated, object: nil)
    }
}
