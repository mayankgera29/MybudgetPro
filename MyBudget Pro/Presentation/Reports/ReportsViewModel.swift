//
//  ReportsViewModel.swift
//  MyBudget Pro
//
//  Created by mayank gera on 19/01/26.
//
import Foundation

final class ReportsViewModel {
    
    // MARK: - Models
    struct CategorySummary {
        let category: CategoryType
        let amount: Double
    }
    
    // MARK: - Dependencies
    private let repository = ExpenseRepository.shared
    private let exchangeService = ExchangeRateService()
    
    // MARK: - Data
    var summaries: [CategorySummary] {
        let grouped = Dictionary(
            grouping: repository.fetchAll(),
            by: { $0.category }
        )
        
        return grouped.map {
            CategorySummary(
                category: $0.key,
                amount: $0.value.reduce(0) { $0 + $1.amount }
            )
        }
        .sorted { $0.amount > $1.amount }
    }
    
    var totalAmount: Double {
        summaries.reduce(0) { $0 + $1.amount }
    }
    
    var maxCategoryAmount: Double {
        summaries.first?.amount ?? 1
    }
    
    var topCategory: CategoryType? {
        summaries.first?.category
    }
    
    var pieSlices: [PieChartView.Slice] {
        summaries.map {
            PieChartView.Slice(
                value: $0.amount,
                color: $0.category.color
            )
        }
    }
    
    // MARK: - 🔝 TOP: INR → USD CONVERSION (SUMMARY)
    func totalConversionText() async -> String {
        
        guard totalAmount > 0 else {
            return CurrencyFormatter.inr(0)
        }
        
        do {
            let rate = try await exchangeService.fetchINRtoUSD()
            let usd = totalAmount * rate
            return "\(CurrencyFormatter.inr(totalAmount))  ≈  \(CurrencyFormatter.usd(usd))"
        } catch {
            // Safe fallback
            let fallbackRate = 0.012
            let usd = totalAmount * fallbackRate
            return "\(CurrencyFormatter.inr(totalAmount))  ≈  \(CurrencyFormatter.usd(usd))"
        }
    }
    
    // MARK: - 🔽 BOTTOM: CATEGORY DIFFERENCE
    func differenceInsightText() -> String {
        
        guard summaries.count > 1 else {
            return "—"
        }
        
        let first = summaries[0].amount
        let second = summaries[1].amount
        
        guard second > 0 else {
            return "—"
        }
        
        let diff = ((first - second) / second) * 100
        let arrow = diff >= 0 ? "📈" : "📉"
        
        return "\(arrow) \(abs(Int(diff)))% difference between top categories"
    }
}
