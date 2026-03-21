//
//  Budget.swift
//  MyBudget Pro
//

import Foundation

struct Budget: Codable {
    let category: CategoryType
    var monthlyLimit: Double
}
