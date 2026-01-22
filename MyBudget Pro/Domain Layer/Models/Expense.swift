//
//  Expense.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//


import Foundation

struct Expense: Codable, Identifiable {
    let id: UUID
    let category: CategoryType
    let amount: Double
    let note: String
    let date: Date
}
