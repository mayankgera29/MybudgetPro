//
//  SplitStorageService.swift
//  MyBudget Pro
//

import Foundation

final class SplitStorageService {

    static let shared = SplitStorageService()
    private init() {}

    private let expensesKey = "split_expenses"
    private let peopleKey   = "split_people"

    // MARK: - Split Expenses
    func saveExpenses(_ expenses: [SplitExpense]) {
        if let data = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(data, forKey: expensesKey)
        }
    }

    func loadExpenses() -> [SplitExpense] {
        guard let data = UserDefaults.standard.data(forKey: expensesKey),
              let expenses = try? JSONDecoder().decode([SplitExpense].self, from: data)
        else { return [] }
        return expenses
    }

    // MARK: - People
    func savePeople(_ people: [Person]) {
        if let data = try? JSONEncoder().encode(people) {
            UserDefaults.standard.set(data, forKey: peopleKey)
        }
    }

    func loadPeople() -> [Person] {
        guard let data = UserDefaults.standard.data(forKey: peopleKey),
              let people = try? JSONDecoder().decode([Person].self, from: data)
        else { return [] }
        return people
    }
}
