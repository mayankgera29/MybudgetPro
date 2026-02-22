//
//  CurrencyFormatter.swift
//  MyBudget Pro
//
//  Created by Mayank Gera on 30/01/26.
//


import Foundation

enum CurrencyFormatter {

    private static let inrFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "INR"
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "en_IN")
        return formatter
    }()

    private static let usdFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()

    static func inr(_ value: Double) -> String {
        inrFormatter.string(from: NSNumber(value: value)) ?? "₹0"
    }

    static func usd(_ value: Double) -> String {
        usdFormatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}