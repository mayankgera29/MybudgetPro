//
//  SplitExpense.swift
//  MyBudget Pro
//

import Foundation

// MARK: - Person
struct Person: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var avatarColor: String  // hex string for persistence

    init(id: UUID = UUID(), name: String, avatarColor: String = "#6366F1") {
        self.id = id
        self.name = name
        self.avatarColor = avatarColor
    }
}

// MARK: - Split Type
enum SplitType: String, Codable {
    case equal              // you paid, split equally — others owe you their share
    case paidByYou          // you paid full for someone — they owe you everything
    case equalPaidByOther   // someone else paid, split equally — you owe your share
    case paidByOtherFull    // someone else paid for you entirely — you owe them full amount
}

// MARK: - Split Share
struct SplitShare: Codable {
    let personId: UUID
    var amount: Double
    var isSettled: Bool
}

// MARK: - Split Expense
struct SplitExpense: Codable, Identifiable {
    let id: UUID
    let category: CategoryType
    let totalAmount: Double
    let note: String
    let date: Date
    let payerId: UUID          // who paid (could be you or someone else)
    let splitType: SplitType
    var shares: [SplitShare]   // per-person breakdown

    init(
        id: UUID = UUID(),
        category: CategoryType,
        totalAmount: Double,
        note: String,
        date: Date,
        payerId: UUID,
        splitType: SplitType,
        shares: [SplitShare]
    ) {
        self.id = id
        self.category = category
        self.totalAmount = totalAmount
        self.note = note
        self.date = date
        self.payerId = payerId
        self.splitType = splitType
        self.shares = shares
    }

    // Amount you are owed (others owe you)
    func amountOwedToYou(yourId: UUID) -> Double {
        guard payerId == yourId else { return 0 }
        return shares
            .filter { $0.personId != yourId && !$0.isSettled }
            .reduce(0) { $0 + $1.amount }
    }

    // Amount you owe (you owe payer)
    func amountYouOwe(yourId: UUID) -> Double {
        guard payerId != yourId else { return 0 }
        return shares
            .filter { $0.personId == yourId && !$0.isSettled }
            .reduce(0) { $0 + $1.amount }
    }
}
