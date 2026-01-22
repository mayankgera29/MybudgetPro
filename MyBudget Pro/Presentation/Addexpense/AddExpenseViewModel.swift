//
//  AddExpenseViewModel.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//

import Foundation
import UIKit
final class AddExpenseViewModel {

    private let repository: ExpenseRepositoryProtocol = ExpenseRepository.shared

    func saveExpense(
        category: CategoryType,
        amount: Double,
        note: String,
        date: Date
    ) {
        let expense = Expense(
            id: UUID(),
            category: category,
            amount: amount,
            note: note,
            date: date
        )
        repository.addExpense(expense)
    }
}
