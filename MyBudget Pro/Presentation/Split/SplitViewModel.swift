//
//  SplitViewModel.swift
//  MyBudget Pro
//

import Foundation

struct BalanceSummary {
    let person: Person
    let netAmount: Double   // positive = they owe you, negative = you owe them
}

final class SplitViewModel {

    private let storage: SplitStorageService
    private(set) var expenses: [SplitExpense] = []
    private(set) var people: [Person] = []

    init(storage: SplitStorageService = .shared) {
        self.storage = storage
        reload()
    }

    func reload() {
        expenses = storage.loadExpenses()
        people   = storage.loadPeople()
    }

    // MARK: - People management
    func addPerson(name: String) -> Person {
        let colors = ["#EF4444","#F97316","#EAB308","#22C55E","#06B6D4","#8B5CF6","#EC4899"]
        let color  = colors[people.count % colors.count]
        let person = Person(name: name, avatarColor: color)
        people.append(person)
        storage.savePeople(people)
        return person
    }

    func deletePerson(id: UUID) {
        people.removeAll { $0.id == id }
        storage.savePeople(people)
    }

    // MARK: - Expense management
    func addExpense(_ expense: SplitExpense) {
        expenses.append(expense)
        storage.saveExpenses(expenses)
    }

    func settleShare(expenseId: UUID, personId: UUID) {
        guard let ei = expenses.firstIndex(where: { $0.id == expenseId }),
              let si = expenses[ei].shares.firstIndex(where: { $0.personId == personId })
        else { return }
        expenses[ei].shares[si].isSettled = true
        storage.saveExpenses(expenses)
    }

    func deleteExpense(id: UUID) {
        expenses.removeAll { $0.id == id }
        storage.saveExpenses(expenses)
    }

    // MARK: - Balance calculation
    func balanceSummaries() -> [BalanceSummary] {
        let meId = UserSession.meId
        var balances: [UUID: Double] = [:]

        for expense in expenses {
            if expense.payerId == meId {
                // I paid — others owe me their share
                for share in expense.shares where share.personId != meId && !share.isSettled {
                    balances[share.personId, default: 0] += share.amount
                }
            } else {
                // Someone else paid — I owe them my share
                if let myShare = expense.shares.first(where: { $0.personId == meId }), !myShare.isSettled {
                    balances[expense.payerId, default: 0] -= myShare.amount
                }
            }
        }

        return balances.compactMap { personId, net in
            guard let person = people.first(where: { $0.id == personId }) else { return nil }
            return BalanceSummary(person: person, netAmount: net)
        }.sorted { abs($0.netAmount) > abs($1.netAmount) }
    }

    // MARK: - Totals
    var totalOwedToYou: Double {
        balanceSummaries().filter { $0.netAmount > 0 }.reduce(0) { $0 + $1.netAmount }
    }

    var totalYouOwe: Double {
        balanceSummaries().filter { $0.netAmount < 0 }.reduce(0) { $0 + abs($1.netAmount) }
    }

    // MARK: - Recent expenses (sorted by date)
    var recentExpenses: [SplitExpense] {
        expenses.sorted { $0.date > $1.date }
    }

    // MARK: - Person lookup
    func person(for id: UUID) -> Person? {
        if id == UserSession.meId { return UserSession.mePerson }
        return people.first { $0.id == id }
    }
}
